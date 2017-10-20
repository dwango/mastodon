import api from '../api';
import { getLocale } from '../locales';
import IntlMessageFormat from 'intl-messageformat';

export const HIGHLIGHT_KEYWORDS_SUCCESS = 'HIGHLIGHT_KEYWORDS_SUCCESS';
export const UPDATE_LAST_NOTIFICATION = 'UPDATE_LAST_NOTIFICATION';

const unescapeHTML = (html) => {
  const wrapper = document.createElement('div');
  wrapper.innerHTML = html;
  return wrapper.textContent;
};

const escapeHTML = (string) => {
  if (typeof string !== 'string') {
    return string;
  }
  return string.replace(/[&'`"<>]/g, function(match) {
    return {
      '&': '&amp;',
      '\'': '&#x27;',
      '`': '&#x60;',
      '"': '&quot;',
      '<': '&lt;',
      '>': '&gt;',
    }[match];
  });
};

const sendHighlightNotification = (dispatch, status, intlMessages, intlLocale) => {
  if (typeof window.Notification !== 'undefined') {
    const last_notification_id = status.id;
    const title = new IntlMessageFormat(intlMessages['notification.highlight'], intlLocale).format({ name: status.account.display_name.length > 0 ? status.account.display_name : status.account.username });
    const body  = (status && status.spoiler_text.length > 0) ? status.spoiler_text : unescapeHTML(status ? status.content : '');

    const notify = new Notification(title, { body, icon: status.account.avatar });
    notify.addEventListener('click', () => {
      window.focus();
      notify.close();
    });

    dispatch({
      type: UPDATE_LAST_NOTIFICATION,
      last_notification_id,
    });
  }
};

export function checkHighlightNotification(status) {
  return (dispatch, getState) => {
    const highlightKeywords = getState().get('highlight_keywords');
    if (highlightKeywords && highlightKeywords.get('keywords').size === 0) {
      return;
    };
    const currentAccountId = getState().getIn(['meta', 'me']);
    const locale = getState().getIn(['meta', 'locale']);
    const { messages } = getLocale();
    const lastNotificationId = highlightKeywords.get('last_notification_id');
    let sendNotificationFlag = false;

    if (status.account.id !== currentAccountId && status.id > lastNotificationId) {
      const contentDom = document.createElement('div');
      const spoilerDom = document.createElement('div');
      if (status.enquete) {
        contentDom.innerHTML = addHighlight(JSON.parse(status.enquete).question, highlightKeywords);
      } else {
        contentDom.innerHTML = addHighlight(status.content, highlightKeywords);
      }
      spoilerDom.innerHTML = addHighlight(status.spoilerHtml, highlightKeywords);
      if (contentDom.getElementsByClassName('highlight').length + spoilerDom.getElementsByClassName('highlight').length > 0 ) {
        sendNotificationFlag = true;
      }
    }

    if (sendNotificationFlag) {
      sendHighlightNotification(dispatch, status, messages, locale);
    }
  };
};

export function refreshHighlightKeywords() {
  return (dispatch, getState) => {
    api(getState).get('/api/v1/highlight_keywords').then(response => {
      dispatch(refreshHighlightKeywordsSuccess(response.data));
    });
  };
}

export function refreshHighlightKeywordsSuccess(keywords) {
  return {
    type: HIGHLIGHT_KEYWORDS_SUCCESS,
    keywords,
  };
}

const ReplaceWith = function(Ele) {
  'use-strict'; // For safari, and IE > 10
  const parent = this.parentNode;
  let i = arguments.length;
  const firstIsNode = +(parent && typeof Ele === 'object');
  if (!parent) return;

  while (i-- > firstIsNode){
    if (parent && typeof arguments[i] !== 'object'){
      arguments[i] = document.createTextNode(arguments[i]);
    } if (!parent && arguments[i].parentNode){
      arguments[i].parentNode.removeChild(arguments[i]);
      continue;
    }
    parent.insertBefore(this.previousSibling, arguments[i]);
  }
  if (firstIsNode) parent.replaceChild(this, Ele);
};

const replaceHighlight = (reg, node) => {
  for (let i = 0; i < node.childNodes.length; i++) {
    const target = node.childNodes[i];
    if (target.nodeName === '#text') {
      const span = document.createElement('span');
      span.innerHTML = escapeHTML(target.textContent)
        .replace(reg, '<span class="highlight">$1</span>');
      if(!target.replaceWith) {
        ReplaceWith.apply(target, span.childNodes);
      } else {
        target.replaceWith.apply(target, span.childNodes);
      }
    } else {
      replaceHighlight(reg, target);
    }
  }
};

export function addHighlight (text, keywords) {
  if (keywords && keywords.get('keywords').size !== 0) {
    const reg = new RegExp(`(${keywords.get('keywords').map(keyword => keyword.get('word').replace(/[-\/\\^$*+?.()|[\]{}]/g, '\\$&')).join('|')})`, 'g');

    const dom = document.createElement('div');
    dom.innerHTML = text;

    replaceHighlight(reg, dom);

    return dom.innerHTML;
  } else {
    return text;
  }
}
