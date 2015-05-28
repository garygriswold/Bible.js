/**
* Unit Tests for Reference
*/
var test1 = new Reference('GEN', 1, 2);
console.log('should be complete verse ', test1);

var test2 = new Reference('GEN:1:2');
console.log('should be complete verse', test2);

var test3 = new Reference('GEN', 1);
console.log('should be book:chapter ', test3);

var test4 = new Reference('GEN:1');
console.log('should be book:chapter ', test4);

var test5 = new Reference('GEN');
console.log('should be book ', test5);

