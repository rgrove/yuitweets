# encoding: utf-8

require 'unicode_utils/each_word'
require 'uri'

module YUITweets; class Bayes
  # Confidence difference. A score for a particular type must be at least this
  # much higher than the score for any other type before that score will be
  # considered a confident classification. This requirement is in addition to
  # the CONFIDENCE_MIN requirement.
  CONFIDENCE_DIFF = 0.3

  # Confidence minimum. A score for a particular type must be at least this high
  # before it will be considered a confident classification. This requirement is
  # in addition to the CONFIDENCE_DIFF requirement.
  CONFIDENCE_MIN = 0.4

  # Regex that matches a complete word string that should be excluded from the
  # corpus.
  #
  # Currently excludes strings that consist entirely of:
  #   - whitespace
  #   - punctuation
  #   - digits
  #   - a single alphanumeric character
  #
  REGEX_EXCLUDE = /^(?:\s+|[[:punct:]]+|\d+|\w)$/

  # Regex that matches a Twitter #hashtag.
  REGEX_HASHTAG = /(?<=^|\W)#(\w{1,32})(?=\W)?/

  # Regex that matches a Twitter @mention.
  REGEX_MENTION = /(?<=^|\W)@(\w{1,16})(?=\W)?/

  # Regex that matches URIs.
  REGEX_URI = URI.regexp(['ftp', 'http', 'https'])

  # Default probability that an unknown word is of a particular classification
  # type.
  SCORE_DEFAULT = 0.0

  def initialize(db)
    @cache   = {}
    @metrics = {}
    @db      = db
    @dirty   = true
    @tokens  = db[:tokens]

    refresh_cache
  end

  # Attempts to classify the type of the specified _text_. Returns the type name
  # if a classification can be made with a high level of confidence, or +nil+
  # otherwise.
  def classify(text)
    scores = score(text).sort {|(a, b), (c, d)| d <=> b }

    if scores.count > 1 &&
        scores[0][1] > CONFIDENCE_MIN &&
        scores[0][1] - scores[1][1] > CONFIDENCE_DIFF

      return scores[0][0]
    end

    nil
  end

  # Returns a Hash containing probability scores for the specified _text_. Keys
  # are type names, value are scores.
  def score(text)
    refresh_cache

    scores = {}
    words  = get_words(text)

    @metrics.each do |type, metrics|
      catch :whitelisted do
        if whitelist = YUITweets::CONFIG[:whitelist][type.to_sym]
          if words.any?{|word| whitelist.include?(word.downcase) }
            scores[type] = 0.999
            throw :whitelisted
          end
        end

        # Create an array of [word, probability] tuples for each word in the text
        # that has an associated probability in the corpus.
        type_words = words.map do |word|
          [word, metrics[word] || SCORE_DEFAULT]
        end

        scores[type] = robinson(type_words) unless type_words.empty?
      end
    end

    scores
  end

  # Trains the corpus that the specified _text_ is of the specified
  # classification _type_.
  def train(type, text)
    type = type.to_s
    raise ArgumentError, "No type specified" if type.empty?

    @db.transaction do
      get_word_hash(text).each do |word, count|
        if @tokens.filter(:type => type, :token => word).count == 0
          @tokens.insert(
            :token => word,
            :type  => type,
            :count => count
          )
        else
          @tokens.filter(:type => type, :token => word).update(
            :count => :count + count
          )
        end
      end
    end

    @dirty = true
  end

  # Untrains the corpus that the specified _text_ is of the specified
  # classification _type_.
  def untrain(type, text)
    type = type.to_s

    @db.transaction do
      get_word_hash(text).each do |word, count|
        trained_count = @tokens.filter(:type => type, :token => word).count

        unless trained_count == 0
          if trained_count - count == 0
            @tokens.filter(:type => type, :token => word).delete
          else
            @tokens.filter(:type => type, :token => word).update(
              :count => :count - count
            )
          end
        end
      end
    end

    @dirty = true
  end

  # private

  def get_words(string)
    stopwords = YUITweets::Config::STOPWORDS
    words     = []

    # Extract URLs from the string. Each URL will be treated as a single word.
    while url = string.slice!(REGEX_URI)
      words << url
    end

    # Extract @mentions from the string.
    while mention = string.slice!(REGEX_MENTION)
      words << mention
    end

    # Extract #hashtags from the string.
    while hashtag = string.slice!(REGEX_HASHTAG)
      words << hashtag unless stopwords.include?(hashtag.downcase)
    end

    UnicodeUtils.each_word(string) do |word|
      unless word.empty? || word =~ REGEX_EXCLUDE || stopwords.include?(word.downcase)
        words << word
      end
    end

    return words
  end

  def get_word_hash(string)
    word_hash = Hash.new(0)
    get_words(string).each {|word| word_hash[word] += 1 }
    word_hash
  end

  def refresh_cache
    return unless @dirty

    @cache   = Hash.new(Hash.new(0))
    @metrics = {}

    # Cache all token info in memory so we don't have to issue thousands of
    # database queries.
    @tokens.group(:type).select(:type).all.each do |row|
      type_cache = @cache[row[:type]] = Hash.new(0)

      @tokens.filter(:type => row[:type]).all.each do |row|
        type_cache[row[:token]] = row[:count]
      end
    end

    total_count = word_count # count of all words in all types

    @cache.each do |type, words|
      type_count  = word_count(type) # count of all words in this type
      other_count = [1, total_count - type_count].max # count of all words in other types
      metrics     = @metrics[type.to_sym] = {}

      words.each do |word, word_count_type|
        word_count_total = word_count(nil, word) # count of this word in all types

        unless word_count_type == 0
          word_count_other = word_count_total - word_count_type

          if type_count > 0
            good = [1.0, word_count_other / type_count.to_f].min
          else
            good = 1.0
          end

          bad  = [1.0, word_count_type / other_count.to_f].min
          prob = bad / (good + bad)

          if (prob - 0.5).abs >= 0.1
            metrics[word] = [0.0, [0.999, prob].min].max
          end
        end
      end
    end

    @dirty = false
  end

  def robinson(words)
    n = 1.0 / words.count
    p = 1.0 - words.map{|w| 1.0 - w[1]}.inject(1.0){|s, v| s * v} ** n
    q = 1.0 - words.map{|w| w[1]}.inject{|s, v| s * v} ** n
    s = (p - q) / (p + q)
    (1 + s) / 2
  end

  def word_count(type = nil, word = nil)
    count = 0

    if type
      if word
        count = @cache[type][word]
      else
        @cache[type].each_value {|c| count += c}
      end
    else
      if word
        @cache.each_value {|w| count += w[word]}
      else
        @cache.each_value {|w| w.each_value {|c| count += c}}
      end
    end

    count
  end
end; end
