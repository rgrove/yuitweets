YUITweets
=========

YUITweets is a Bayesian tweet classifier that can learn how to distinguish between tweets about the YUI Library and tweets about J-pop idols named Yui.

It consists of two parts:

1. A Sinatra app that provides a simple voting interface to classify tweets as YUI-related or not YUI-related, as well as RSS feeds for each category of tweets.

2. A standalone Ruby executable that retrieves Twitter search results, stores them in the database, and attempts to automatically classify them if the classifier is confident enough.

Usage
-----

The best way to use YUITweets is via the official public installation at http://tweet.yuilibrary.com/. This version already has a large classification corpus, and is quickly getting even better at classifying tweets.

If you'd like to hack on your own instance of YUITweets, you'll need Ruby 1.9.1 or higher, SQLite 3.7.x, and any Rack-compatible web server. Thin is my favorite. If you don't already have Thin installed, run:

    gem install thin

Next, clone the YUITweets git repo:

    git clone git://github.com/rgrove/yuitweets.git
    cd yuitweets

Build and install the gem to pull in necessary dependencies:

    rake install

Create a development database:

    rake migrate[sqlite://db/development.db]

Now you should be ready to pull in some tweets and run the local server:

    rake tweets
    rake devserver

If that worked, YUITweets should be alive at http://localhost:3000/.

Contributing
------------

Patches are more than welcome. Please fork the GitHub repo, create a topic branch for your change, commit your change to the branch, and then send me (rgrove) a GitHub pull request from your branch with a description of the change and why you think I should pick it up.

License
-------

Copyright (c) 2010 Ryan Grove (ryan@wonko.com)

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the 'Software'), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED 'AS IS', WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
