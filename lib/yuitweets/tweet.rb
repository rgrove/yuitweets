require 'htmlentities'
require 'time'
require 'yajl'

module YUITweets; class Tweet < Sequel::Model
  # Class methods.

  def self.last_id
    reverse_order(:id).get(:id) || 0
  end

  def self.recent(options = {})
    options = {
      :limit => 20,
      :type  => nil
    }.merge(options)

    dataset = filter(:type => options[:type]).limit(options[:limit]).
        reverse_order(:id)

    if options[:since_id]
      dataset = dataset.filter('id > ?', options[:since_id])
    end

    dataset
  end

  # Instance methods.

  def method_missing(name)
    tweet[name]
  end

  def scores(refresh = false)
    return @scores unless refresh || @scores.nil?
    @scores = YUITweets.bayes.score(specimen)
  end

  def specimen
    @specimen ||= HTMLEntities.new.decode("@#{from_user} #{text}")
  end

  def to_hash(merge = {}, include_scores = false)
    hash = {
      :id     => id,
      :tweet  => tweet,
      :type   => type,
      :votes  => votes
    }.merge(merge)

    hash[:scores] = scores if include_scores
    hash
  end

  def tweet
    @tweet ||= Yajl::Parser.parse(self[:tweet], :symbolize_keys => true)
  end
end; end
