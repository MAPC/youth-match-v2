import Ember from 'ember';

export function prettifyCamelCase(params/*, hash*/) {
  let str = params[0];
  if(typeof str !== 'string') return;
  let output = "";
  let len = str.length;
  let char;

  for (let i=0 ; i<len ; i++) {
      char = str.charAt(i);

      if (i==0) {
          output += char.toUpperCase();
      }
      else if (char !== char.toLowerCase() && char === char.toUpperCase()) {
          output += " " + char;
      }
      else if (char == "-" || char == "_") {
          output += " ";
      }
      else {
          output += char;
      }
  }

  return output;
}

export default Ember.Helper.helper(prettifyCamelCase);
