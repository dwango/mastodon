import emojione from 'emojione';

const toImage = str => nicoruToImage(shortnameToImage(unicodeToImage(str)));

const unicodeToImage = str => {
  const mappedUnicode = emojione.mapUnicodeToShort();

  return str.replace(emojione.regUnicode, unicodeChar => {
    if (typeof unicodeChar === 'undefined' || unicodeChar === '' || !(unicodeChar in emojione.jsEscapeMap)) {
      return unicodeChar;
    }

    const unicode  = emojione.jsEscapeMap[unicodeChar];
    const short    = mappedUnicode[unicode];
    const filename = emojione.emojioneList[short].fname;
    const alt      = emojione.convert(unicode.toUpperCase());

    return `<img draggable="false" class="emojione" alt="${alt}" src="/emoji/${filename}.svg" />`;
  });
};

const shortnameToImage = str => str.replace(emojione.regShortNames, shortname => {
  if (typeof shortname === 'undefined' || shortname === '' || !(shortname in emojione.emojioneList)) {
    return shortname;
  }

  const unicode = emojione.emojioneList[shortname].unicode[emojione.emojioneList[shortname].unicode.length - 1];
  const alt     = emojione.convert(unicode.toUpperCase());

  return `<img draggable="false" class="emojione" alt="${alt}" src="/emoji/${unicode}.svg" />`;
});

const nicoruToImage = str => str.replace(/:nicoru(\d*):/g, (match, deg) => {
  deg = deg ? deg : 0;
  return `<img draggable="false" class="emojione" alt="${match}" src="${NicoruImages.main}" style="transform:rotate(${deg}deg);" />`;
});

export default function emojify(text) {
  return toImage(text);
};
