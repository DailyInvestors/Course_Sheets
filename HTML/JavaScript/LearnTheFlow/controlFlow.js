/**
 * JavaScript Control Flow Tutorial
 *
 * Control flow is the order in which a computer executes statements in a script.
 * In JavaScript, we have several constructs to manage this flow:
 * 1. Conditional Statements (if, else if, else, switch)
 * 2. Loop Statements (for, while, do...while, for...of, for...in)
 * 3. Break and Continue Statements
 * 4. Function Calls (implicitly control flow by executing blocks of code)
 */

console.log("--- Starting Control Flow Tutorial ---");

// --- 1. Conditional Statements ---

console.log("\n--- Conditional Statements (if, else if, else) ---");

let age = 20;

if (age < 13) {
  console.log("You are a child.");
} else if (age >= 13 && age < 18) {
  console.log("You are a teenager.");
} else if (age >= 18 && age < 65) {
  console.log("You are an adult.");
} else {
  console.log("You are a senior citizen.");
}
// Try changing the 'age' variable to see different outputs!

console.log("\n--- Conditional Statements (switch) ---");

let dayOfWeek = "Wednesday";

switch (dayOfWeek) {
  case "Monday":
    console.log("It's the start of the week!");
    break; // 'break' is crucial to exit the switch statement
  case "Wednesday":
    console.log("Happy Hump Day!");
    break;
  case "Friday":
    console.log("TGIF!");
    break;
  default:
    console.log("It's just another day.");
}
// Try changing 'dayOfWeek' to see different cases executed.

// --- 2. Loop Statements ---

console.log("\n--- Loop Statements (for loop) ---");

// The 'for' loop is used when you know how many times you want to loop.
for (let i = 0; i < 5; i++) {
  console.log("For loop iteration: " + i);
}

console.log("\n--- Loop Statements (while loop) ---");

// The 'while' loop executes a block of code as long as a specified condition is true.
let count = 0;
while (count < 3) {
  console.log("While loop iteration: " + count);
  count++; // Don't forget to update the condition variable to avoid infinite loops!
}

console.log("\n--- Loop Statements (do...while loop) ---");

// The 'do...while' loop is similar to 'while', but it guarantees the block of code
// will be executed at least once, even if the condition is initially false.
let x = 0;
do {
  console.log("Do...while loop iteration: " + x);
  x++;
} while (x < 1); // This loop will run once. If 'x' was already 1, it would still run once.

console.log("\n--- Loop Statements (for...of loop - for iterating over iterable objects like arrays) ---");

const fruits = ["apple", "banana", "cherry"];
for (const fruit of fruits) {
  console.log("Fruit: " + fruit);
}

console.log("\n--- Loop Statements (for...in loop - for iterating over enumerable properties of an object) ---");

const person = {
  name: "Alice",
  age: 30,
  city: "New York"
};
for (const key in person) {
  console.log(key + ": " + person[key]);
}

// --- 3. Break and Continue Statements ---

console.log("\n--- Break and Continue Statements ---");

for (let i = 0; i < 10; i++) {
  if (i === 3) {
    console.log("Encountered 3, skipping this iteration with 'continue'.");
    continue; // Skips the rest of the current loop iteration and moves to the next.
  }
  if (i === 7) {
    console.log("Encountered 7, stopping the loop with 'break'.");
    break; // Exits the loop entirely.
  }
  console.log("Current number: " + i);
}

// --- 4. Function Calls (Implicit Control Flow) ---

console.log("\n--- Function Calls (Implicit Control Flow) ---");

// When a function is called, the control flow jumps to the function's code block,
// executes it, and then returns to where it was called.
function greet(name) {
  console.log("Hello, " + name + "!");
}

console.log("Calling the 'greet' function...");
greet("Bob");
console.log("Back from calling the 'greet' function.");


console.log("\n--- Control Flow Tutorial Complete ---");
