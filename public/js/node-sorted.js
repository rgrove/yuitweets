YUI.add('node-sorted', function (Y) {

var YArray = Y.Array;

function Sorted(config) {
    Sorted.superclass.constructor.apply(this, arguments);
}

Y.namespace('Plugin').Sorted = Y.extend(Sorted, Y.Plugin.Base, {
    initializer: function (config) {
        this._node             = config.host;
        this._node.sort        = Y.bind(this.sort, this);
        this._node.reverseSort = Y.bind(this.sort, this, true);
    },

    reverseSort: function () {
        return this.sort(true);
    },

    sort: function (reverse) {
        var anchor,
            buffer      = [],
            descendants = this.get('descendants'),
            needsSort,
            sorted;

        // Nothing to do if there aren't at least two nodes.
        if (descendants.size() < 2) {
            return this._node;
        }

        // Create an anchor node to serve as a fixed reference point when
        // reordering nodes.
        anchor = Y.one(Y.config.doc.createTextNode(''));
        descendants.item(0).insert(anchor, 'before');

        // Convert the descendants nodelist to an array and sort it.
        sorted = YArray.map(Y.NodeList.getDOMNodes(descendants), Y.one);
        sorted.sort(this.get('comparator'));

        if (reverse) {
            sorted.reverse();
        }

        // Avoid moving nodes around if the sort hasn't changed any node
        // positions.
        needsSort = YArray.some(sorted, function (node, index) {
            return node !== descendants.item(index);
        });

        if (needsSort) {
            // Move the nodes into their new positions.
            YArray.each(sorted, function (node) {
                node.remove();
                anchor.insert(node, 'before');
            });
        }

        anchor.remove();

        return this._node;
    }
}, {
    NAME: 'sortedPlugin',
    NS  : 'sorted',

    ATTRS: {
        comparator: {
            valueFn: function () {
                return Sorted.textComparator;
            }
        },

        descendants: {
            getter: function (value) {
                return this._node.all(value);
            },

            value: '>*'
        }
    },

    // -- Static Methods -------------------------------------------------------
    idComparator: function (a, b) {
        var aId = a.get('id').toLowerCase(),
            bId = b.get('id').toLowerCase();

        if (aId < bId) {
            return -1;
        } else if (aId > bId) {
            return 1;
        }

        return 0;
    },

    textComparator: function (a, b) {
        var aText = a.get('text').toLowerCase(),
            bText = b.get('text').toLowerCase();

        if (aText < bText) {
            return -1;
        } else if (aText > bText) {
            return 1;
        }

        return 0;
    }
});

}, '@VERSION@', {
    requires: ['array-extras', 'plugin']
});
