export default function capitalize(words) {
  const blacklist = ['and', 'than'];

  const capitalized = words.split(' ')
                           .map(word => (blacklist.indexOf(word) === -1) ? word.charAt(0).toUpperCase() + word.slice(1) : word)
                           .join(' ');
  return capitalized;
}
