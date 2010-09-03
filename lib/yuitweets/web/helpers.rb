module YUITweets; class Web < Sinatra::Base

  helpers do
    def json_error(code, message = 'Unknown error')
      error(code, Yajl::Encoder.encode({:error => message}))
    end

    def json_success(data = nil, message = 'Yay!')
      body = {:success => message}
      body[:data] = data unless data.nil?

      Yajl::Encoder.encode(body)
    end

    def recent_tweets
      @limit    = (params[:limit] || 20).to_i
      @since_id = (params[:since_id] || 0).to_i
      @type     = params[:type]

      if @type.nil?
        results = []

        ['yui', nil, 'other'].each do |type|
          results += Tweet.recent(
            :limit    => @limit,
            :since_id => @since_id,
            :type     => type
          ).all
        end
      else
        results = Tweet.recent(
          :limit    => @limit,
          :since_id => @since_id,
          :type     => @type == 'unknown' ? nil : @type
        ).all
      end

      results.sort_by! {|tweet| tweet.id }
      results.reverse!
      results
    end

    def render_tweet(tweet)
      show_scores = !params[:show_scores].nil?
      erubis(:'partials/tweet', :locals => {:tweet => tweet, :show_scores => show_scores})
    end

    # Returns the approximate difference between two Time objects in English.
    # Based on distance_of_time_in_words in the Rails ActionView DateHelper.
    def time_diff_in_words(from, to = Time.now, include_seconds = false)
      raw_seconds = (to - from).abs
      minutes     = (raw_seconds / 60).round
      seconds     = raw_seconds.round

      case minutes
        when 0..1
          unless include_seconds
            if minutes == 0
              return 'less than a minute'
            elsif minutes == 1
              return '1 minute'
            else
              return "#{minutes} minutes"
            end
          end

          case seconds
            when 0..4   then 'less than 5 seconds'
            when 5..9   then 'less than 10 seconds'
            when 10..19 then 'less than 20 seconds'
            when 20..39 then 'half a minute'
            when 40..59 then 'less than a minute'
            else             '1 minute'
          end

        when 2..44           then "#{minutes} minutes"
        when 45..89          then 'about an hour'
        when 90..1439        then "#{(minutes.to_f / 60.0).round} hours"
        when 1440..2879      then 'about a day'
        when 2880..43199     then "#{(minutes / 1440).round} days"
        when 43200..86399    then 'about a month'
        when 86400..525599   then "#{(minutes / 43200).round} months"
        when 525600..1051199 then 'about a year'
        else                      "#{(minutes / 525600).round} years"
      end
    end

    def url_tweet(tweet)
      "#{url_user(tweet.from_user)}/status/#{tweet.id}"
    end

    def url_user(user)
      "http://twitter.com/#{escape(user)}"
    end
  end

end; end