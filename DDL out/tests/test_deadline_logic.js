const assert = require('node:assert/strict');
const { normalizeRemainingTime } = require('../static/js/script.js');

assert.deepEqual(
    normalizeRemainingTime(0, 24, 0),
    { days: 1, hours: 0, minutes: 0 }
);
assert.deepEqual(
    normalizeRemainingTime(0, 25, 0),
    { days: 1, hours: 1, minutes: 0 }
);
assert.deepEqual(
    normalizeRemainingTime(0, 0, 60),
    { days: 0, hours: 1, minutes: 0 }
);
assert.deepEqual(
    normalizeRemainingTime(0, 23, 120),
    { days: 1, hours: 1, minutes: 0 }
);
assert.deepEqual(
    normalizeRemainingTime(1, 48, 120),
    { days: 3, hours: 2, minutes: 0 }
);

console.log('deadline carry tests passed');
