require 'builder'
require 'erubis'
require 'htmlentities'
require 'sinatra/base'

require 'yuitweets'
require 'yuitweets/web/helpers'

module YUITweets; class Web < Sinatra::Base
  set :logging, true if development?
  set :root, ROOT_DIR

  get '/' do
    content_type('text/html', :charset => 'utf-8')
    erubis(:index)
  end

  get '/recent.json' do
    content_type('application/json', :charset => 'utf-8')

    results = recent_tweets

    if results.empty?
      json_success({
        :limit    => @limit,
        :since_id => @since_id
      })
    else
      json_success({
        :add      => results.map {|t| t.to_hash(:html => render_tweet(t)) },
        :limit    => @limit,
        :max_id   => results.first && results.first.id || 0,
        :since_id => @since_id
      })
    end
  end

  get '/recent.rss' do
    content_type('application/rss+xml', :charset => 'utf-8')

    results  = recent_tweets
    entities = HTMLEntities.new

    x = Builder::XmlMarkup.new(:indent => 2)
    x.instruct!

    x.rss(:version     => '2.0',
          'xmlns:atom' => 'http://www.w3.org/2005/Atom',
          'xmlns:dc'   => 'http://purl.org/dc/elements/1.1/') do

      x.channel do
        x.title 'YUI Tweets'
        x.link  'http://yuitweets.pieisgood.org/'
        x.ttl   5

        results.each do |tweet|
          tweet_url = url_tweet(tweet)

          x.item do
            x.title   entities.decode(tweet.text)
            x.link    tweet_url
            x.dc      :creator, tweet.from_user
            x.guid    tweet_url, :isPermaLink => 'true'
            x.pubDate tweet.created_at.rfc2822
          end
        end
      end
    end

    x.target!
  end

  post '/vote.json' do
    content_type('application/json', :charset => 'utf-8')

    id    = params[:id] or json_error(400, "Missing required parameter: id")
    type  = params[:type] or json_error(400, "Missing required parameter: type")
    type.downcase!

    tweet = Tweet[id.to_i] or json_error(400, "Tweet id not found: #{id.to_i}")

    # Don't retrain if the tweet has already been trained as this type.
    if tweet.type != type
      unless tweet.type.nil?
        # Tweet was previously trained as a different type, so untrain it before
        # retraining.
        YUITweets.bayes.untrain(tweet.type, tweet.specimen)
      end

      YUITweets.bayes.train(type, tweet.specimen)
    end

    tweet.update(
      :type  => type,
      :votes => tweet.votes + 1
    )

    json_success({
      :update => [tweet.to_hash(:html => render_tweet(tweet))]
    })
  end
end; end
