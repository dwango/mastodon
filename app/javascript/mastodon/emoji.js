import { unicodeMapping } from './emojione_light';
import Trie from 'substring-trie';
import NicoruImages from './nicoru';

const trie = new Trie(Object.keys(unicodeMapping));

const emojify = str => {
  let rtn = '';
  for (;;) {
    let match, i = 0;
    while (i < str.length && str[i] !== '<' && !(match = trie.search(str.slice(i)))) {
      i += str.codePointAt(i) < 65536 ? 1 : 2;
    }
    if (i === str.length)
      break;
    else if (str[i] === '<') {
      let tagend = str.indexOf('>', i + 1) + 1;
      if (!tagend)
        break;
      rtn += str.slice(0, tagend);
      str = str.slice(tagend);
    } else {
      const [filename, shortCode] = unicodeMapping[match];
      rtn += str.slice(0, i) + `<img draggable="false" class="emojione" alt="${match}" title=":${shortCode}:" src="/emoji/${filename}.svg" />`;
      str = str.slice(i + match.length);
    }
  }
  return rtn + str;
};

const nicoruToImage = str => str.replace(/:nicoru(\d*):/g, (match, deg) => {
  deg = deg ? deg : 0;
  return `<img draggable="false" class="emojione" alt="${match}" src="${NicoruImages.main}" style="transform:rotate(${deg}deg);" />`;
});

const profileEmojify = (str, profileEmojiMap) => {
  // Replace custom emoji string, ignoring any tags and spaces
  // e.g. ':@foo:' -> '<img alt="foo.png" />'
  // e.g. ':<span><a>@<span>foo</span> </a></span>:' -> '<img alt="foo.png" />'
  // Reference: https://github.com/tootsuite/mastodon/pull/4988
  let i = -1;
  let insideTag = false;
  let insideColon = false;
  let shortname = '';
  let shortnameStartIndex = -1;

  while (++i < str.length) {
    const char = str.charAt(i);
    if (char === '<') {
      insideTag = true;
    } else if (insideTag && char === '>') {
      insideTag = false;
    } else if (!insideTag) {
      if (!insideColon && char === ':') {
        insideColon = true;
        shortname = '';
        shortnameStartIndex = i;
      } else if (insideColon && char === ':') {
        insideColon = false;
        const strippedShortname = shortname.substring(1);
        if (shortname[0] === '@' && strippedShortname in profileEmojiMap) {
          const { url, account_url } = profileEmojiMap[strippedShortname];
          const replacement = `<a href="${account_url}" class="profile-emoji" data-account-name="${strippedShortname}">`
                            +   `<img draggable="false" class="emojione" alt=":${shortname}:" title=":${shortname}:" src="${url}" />`
                            + '</a>';
          str = str.substring(0, shortnameStartIndex) + replacement + str.substring(i + 1);
          i = shortnameStartIndex + replacement.length - 1; // jump ahead the length we've added to the string
        } else {
          i--;
        }
      } else if (insideColon && char ) {
        if (char !== ' ') {
          shortname += char;
        }
      }
    }
  }
  return str;
};

const _emojify = (str, profileEmojiMap = {}) => profileEmojify(nicoruToImage(emojify(str)), profileEmojiMap);

export default _emojify;
