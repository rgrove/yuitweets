var Y = YUI().use('cookie', 'event-key', 'io-base', 'json-parse', 'node', 'node-sorted', function (Y) {

var YArray = Y.Array,

    COOKIE_NAME = 'yuitweets',

    URL_RECENT = '/recent.json',
    URL_VOTE   = '/vote.json',

    maxId = 0,

    nodeOther   = Y.one('#other'),
    nodeUnknown = Y.one('#unknown'),
    nodeYUI     = Y.one('#yui'),

    showScores  = window.location.search.search(/[?&]show_scores(?:[=&]|$)/) !== -1;

// -- Private Functions --------------------------------------------------------
function addTweet(tweet, prepend) {
    var parentNode,
        tweetNode = Y.Node.create(tweet.html);

    switch (tweet.type) {
    case 'other':
        parentNode = nodeOther;
        break;

    case 'yui':
        parentNode = nodeYUI;
        break;

    default:
        parentNode = nodeUnknown;
    }

    tweetNode.setData('tweet', tweet);

    decorateTweetNode(tweetNode);
    parentNode[prepend ? 'prepend' : 'append'](tweetNode);
}

function addTweets(tweets, prepend) {
    YArray.each(tweets, function (tweet) {
        addTweet(tweet, prepend);
    });

    Y.Cookie.setSub(COOKIE_NAME, 'last_seen_id', maxId, {
        expires: getCookieDate()
    });
}

function decorateTweetNode(node) {
    var lastSeenId = +Y.Cookie.getSub(COOKIE_NAME, 'last_seen_id') || 0,
        tweet      = node.getData('tweet');

    if (!tweet) {
        return;
    }

    // Is this a tweet the user hasn't seen before?
    node[lastSeenId < tweet.id ? 'addClass' : 'removeClass']('new');

    // Was this tweet auto-classified?
    node[tweet.type && !tweet.votes ? 'addClass' : 'removeClass']('auto');
}

function getCookieDate() {
    var date = new Date();
    date.setTime(date.getTime() + 7776000000); // +90 days
    return date;
}

function parseJSON(json) {
    var data;

    try {
        data = Y.JSON.parse(json);
    } catch (ex) {
        Y.error('Error parsing JSON.');
    }

    return data;
}

function refreshTweets(changes) {
    if (changes.add) {
        if (changes.max_id && changes.max_id > maxId) {
            maxId = changes.max_id;
        }

        addTweets(changes.add);
    }

    if (changes.update) {
        updateTweets(changes.update);
    }

    nodeOther.reverseSort();
    nodeYUI.reverseSort();
}

function removeTweetNode(tweetNode) {
    // TODO: fancy animations
    return tweetNode.remove();
}

function requestTweets(type, sinceId) {
    var url  = URL_RECENT,
        data = [];

    if (type) {
        data.push('type=' + encodeURIComponent(type));
    }

    if (sinceId) {
        data.push('since_id=' + sinceId);
    }

    if (showScores) {
        data.push('show_scores=1');
    }

    if (data.length) {
        url += '?' + data.join('&');
    }

    Y.io(url, {
        arguments: type,
        on: {
            end    : onRequestEnd,
            failure: onRequestFailure,
            start  : onRequestStart,
            success: onRequestSuccess
        },
        timeout: 10000
    });
}

function tweetNodeComparator(a, b) {
    var aId = +a.getAttribute('data-tweet-id'),
        bId = +b.getAttribute('data-tweet-id');

    return aId - bId;
}

function updateTweets(tweets) {
    YArray.each(tweets, function (newTweet) {
        var oldTweet,
            tweetNode = Y.one('#tweet-' + newTweet.id);

        if (!tweetNode) {
            Y.error('Tweet node not found: ' + newTweet.id);
            return;
        }

        oldTweet = tweetNode.getData('tweet');
        newTweet = Y.merge(oldTweet, newTweet);
        tweetNode.setData('tweet', newTweet);

        if (oldTweet.type === newTweet.type) {
            decorateTweetNode(tweetNode);
        } else {
            removeTweetNode(tweetNode);
            addTweet(newTweet, true);
        }
    });
}

function vote(id, type) {
    var data = [
        'id=' + id,
        'type=' + encodeURIComponent(type)
    ];

    if (showScores) {
        data.push('show_scores=1');
    }

    Y.io(URL_VOTE, {
        data: data.join('&'),
        method: 'POST',
        on: {
            failure : onVoteFailure,
            success : onVoteSuccess
        },
        timeout: 10000
    });
}

// -- Private Event Handlers ---------------------------------------------------
function onKeyDown(e) {
    var firstUnknown = nodeUnknown.one('.tweet');

    if (!firstUnknown) {
        return;
    }

    firstUnknown = firstUnknown.getAttribute('data-tweet-id');

    switch (e.keyCode) {
    case 37: // left arrow
        vote(firstUnknown, 'yui');
        break;

    case 39: // right arrow
        vote(firstUnknown, 'other');
        break;
    }

    e.preventDefault();
}

function onRequestEnd(conn, type) {
    if (type) {
        Y.one('#' + type).removeClass('loading');
    } else {
        Y.all('.tweets').removeClass('loading');
    }
}

function onRequestFailure(conn, response) {
    // TODO: handle failures
}

function onRequestSuccess(conn, response) {
    response = parseJSON(response.responseText);

    if (response.data) {
        refreshTweets(response.data);
    }
}

function onRequestStart(conn, type) {
    if (type) {
        Y.one('#' + type).addClass('loading');
    } else {
        Y.all('.tweets').addClass('loading');
    }
}

function onVoteDown(e) {
    vote(e.currentTarget.getAttribute('data-tweet-id'), 'other');
}

function onVoteFailure(conn, response) {
    // TODO: handle failures
}

function onVoteSuccess(conn, response) {
    response = parseJSON(response.responseText);

    if (response.data) {
        refreshTweets(response.data);
    }

    if (!nodeUnknown.one('.tweet')) {
        requestTweets('unknown');
    }
}

function onVoteUp(e) {
    vote(e.currentTarget.getAttribute('data-tweet-id'), 'yui');
}

// -- Initialization -----------------------------------------------------------
requestTweets();

// If the browser has a touchstart event, we'll turn off the hover requirement
// and show all voting buttons by default. This isn't perfect, but it's better
// than nothing.
if ('ontouchstart' in Y.config.win) {
    Y.one('body').addClass('touch');
}

Y.later(60000, null, function () {
    requestTweets(null, maxId);
}, null, true);

Y.delegate('click', onVoteDown, 'body', '.vote-down');
Y.delegate('click', onVoteUp, 'body', '.vote-up');
Y.on('key', onKeyDown, Y.config.doc, 'down:37,39+shift');

nodeOther.plug(Y.Plugin.Sorted, {comparator: tweetNodeComparator});
nodeYUI.plug(Y.Plugin.Sorted, {comparator: tweetNodeComparator});

});
