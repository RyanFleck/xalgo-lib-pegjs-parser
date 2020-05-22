import { add } from '../src/index';

test('Sum function adds 1 and 2', () => {
    expect(add(1, 2)).toBe(3);
});
