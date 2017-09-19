import React from 'react';
import AutosuggestAccountContainer from '../features/compose/containers/autosuggest_account_container';
import AutosuggestEmoji from '../features/compose/components/autosuggest_emoji';
import ImmutablePropTypes from 'react-immutable-proptypes';
import PropTypes from 'prop-types';
import { isRtl } from '../rtl';
import ImmutablePureComponent from 'react-immutable-pure-component';
import Textarea from 'react-textarea-autosize';

const textAtCursorMatchesToken = (str, caretPosition) => {
  let word;

  let left  = str.slice(0, caretPosition).search(/\S+$/);
  let right = str.slice(caretPosition).search(/\s/);

  if (right < 0) {
    word = str.slice(left);
  } else {
    word = str.slice(left, right + caretPosition);
  }

  if (!word || word.trim().length < 2 || word[0] !== '@') {
    return [null, null];
  }

  word = word.trim().toLowerCase().slice(1);

  if (word.length > 0) {
    return [left + 1, word];
  } else {
    return [null, null];
  }
};

const textAtCursorMatchesEmojiToken = (str, caretPosition) => {
  let word;

  let left  = str.slice(0, caretPosition).search(/\S+$/);
  let right = str.slice(caretPosition).search(/\s/);

  if (right < 0) {
    word = str.slice(left);
  } else {
    word = str.slice(left, right + caretPosition);
  }

  if (!word || word.trim().length < 2 || word[0] !== ':') {
    return [null, null];
  }

  word = word.trim().toLowerCase().slice(1);

  if (word.length > 1 && word[0] === '@') {
    return [left + 1, word];
  } else {
    return [null, null];
  }
};

export default class AutosuggestTextarea extends ImmutablePureComponent {

  static propTypes = {
    value: PropTypes.string,
    suggestions: ImmutablePropTypes.list,
    disabled: PropTypes.bool,
    placeholder: PropTypes.string,
    onSuggestionSelected: PropTypes.func.isRequired,
    onSuggestionsClearRequested: PropTypes.func.isRequired,
    onSuggestionsFetchRequested: PropTypes.func.isRequired,
    onChange: PropTypes.func.isRequired,
    onKeyUp: PropTypes.func,
    onKeyDown: PropTypes.func,
    onPaste: PropTypes.func.isRequired,
    autoFocus: PropTypes.bool,
    emojiSuggestions: ImmutablePropTypes.list,
    onProfileEmojiSuggestionSelected: PropTypes.func.isRequired,
    onProfileEmojiSuggestionsFetchRequested: PropTypes.func.isRequired,
    onProfileEmojiSuggestionsClearRequested: PropTypes.func.isRequired,
  };

  static defaultProps = {
    autoFocus: true,
  };

  state = {
    suggestionsHidden: false,
    selectedSuggestion: 0,
    lastToken: null,
    tokenStart: 0,
  };

  onChange = (e) => {
    const [ tokenStart, token ] = textAtCursorMatchesToken(e.target.value, e.target.selectionStart);
    const [ emojiTokenStart, emojiToken ] = textAtCursorMatchesEmojiToken(e.target.value, e.target.selectionStart);

    if (token !== null && this.state.lastToken !== token) {
      this.setState({ lastToken: token, selectedSuggestion: 0, tokenStart });
      this.props.onSuggestionsFetchRequested(token);
    } else if (emojiToken !== null && this.state.lastToken !== emojiToken) {
      // emojiToken contains first '@' sigil
      if (emojiToken[0] === '@') {
        this.setState({ lastToken: emojiToken.slice(1), selectedSuggestion: 0, tokenStart: emojiTokenStart });
        this.props.onProfileEmojiSuggestionsFetchRequested(emojiToken.slice(1));
      }
    } else {
      if (token === null) {
        this.setState({ lastToken: null });
        this.props.onSuggestionsClearRequested();
      }
      if (emojiToken === null) {
        this.setState({ lastToken: null });
        this.props.onProfileEmojiSuggestionsClearRequested();
      }
    }

    this.props.onChange(e);
  }

  onKeyDown = (e) => {
    const { suggestions, emojiSuggestions, disabled } = this.props;
    const { selectedSuggestion, suggestionsHidden } = this.state;

    if (disabled) {
      e.preventDefault();
      return;
    }

    switch(e.key) {
    case 'Escape':
      if (!suggestionsHidden) {
        e.preventDefault();
        this.setState({ suggestionsHidden: true });
      }

      break;
    case 'ArrowDown':
      if (suggestions.size > 0 && !suggestionsHidden) {
        e.preventDefault();
        this.setState({ selectedSuggestion: Math.min(selectedSuggestion + 1, suggestions.size - 1) });
      }
      if (emojiSuggestions.size > 0 && !suggestionsHidden) {
        e.preventDefault();
        this.setState({ selectedSuggestion: Math.min(selectedSuggestion + 1, emojiSuggestions.size - 1) });
      }

      break;
    case 'ArrowUp':
      if (suggestions.size > 0 && !suggestionsHidden) {
        e.preventDefault();
        this.setState({ selectedSuggestion: Math.max(selectedSuggestion - 1, 0) });
      }
      if (emojiSuggestions.size > 0 && !suggestionsHidden) {
        e.preventDefault();
        this.setState({ selectedSuggestion: Math.max(selectedSuggestion - 1, 0) });
      }

      break;
    case 'Enter':
    case 'Tab':
      // Select suggestion
      if (this.state.lastToken !== null && suggestions.size > 0 && !suggestionsHidden) {
        e.preventDefault();
        e.stopPropagation();
        this.props.onSuggestionSelected(this.state.tokenStart, this.state.lastToken, suggestions.get(selectedSuggestion));
      }
      if (this.state.lastToken !== null && emojiSuggestions.size > 0 && !suggestionsHidden) {
        e.preventDefault();
        e.stopPropagation();
        this.props.onProfileEmojiSuggestionSelected(this.state.tokenStart, this.state.lastToken, emojiSuggestions.getIn([selectedSuggestion, 'shortcode']));
      }

      break;
    }

    if (e.defaultPrevented || !this.props.onKeyDown) {
      return;
    }

    this.props.onKeyDown(e);
  }

  onBlur = () => {
    this.setState({ suggestionsHidden: true });
  }

  onSuggestionClick = (e) => {
    const suggestion = Number(e.currentTarget.getAttribute('data-index'));
    e.preventDefault();
    this.props.onSuggestionSelected(this.state.tokenStart, this.state.lastToken, suggestion);
    this.textarea.focus();
  }

  onProfileEmojiSuggestionClick = (e) => {
    const index = Number(e.currentTarget.getAttribute('data-index'));
    const completion = this.props.emojiSuggestions.getIn([index, 'shortcode']);
    e.preventDefault();
    this.props.onProfileEmojiSuggestionSelected(this.state.tokenStart, this.state.lastToken, completion);
    this.textarea.focus();
  }

  componentWillReceiveProps (nextProps) {
    if (nextProps.suggestions !== this.props.suggestions && nextProps.suggestions.size > 0 && this.state.suggestionsHidden) {
      this.setState({ suggestionsHidden: false });
    }
  }

  setTextarea = (c) => {
    this.textarea = c;
  }

  onPaste = (e) => {
    if (e.clipboardData && e.clipboardData.files.length === 1) {
      this.props.onPaste(e.clipboardData.files);
      e.preventDefault();
    }
  }

  render () {
    const { value, suggestions, disabled, placeholder, onKeyUp, autoFocus, emojiSuggestions } = this.props;
    const { suggestionsHidden, selectedSuggestion } = this.state;
    const style = { direction: 'ltr' };
    const isSuggestionsHidden = suggestionsHidden || (suggestions.isEmpty() && emojiSuggestions.isEmpty());

    if (isRtl(value)) {
      style.direction = 'rtl';
    }

    return (
      <div className='autosuggest-textarea'>
        <label>
          <span style={{ display: 'none' }}>{placeholder}</span>
          <Textarea
            inputRef={this.setTextarea}
            className='autosuggest-textarea__textarea'
            disabled={disabled}
            placeholder={placeholder}
            autoFocus={autoFocus}
            value={value}
            onChange={this.onChange}
            onKeyDown={this.onKeyDown}
            onKeyUp={onKeyUp}
            onBlur={this.onBlur}
            onPaste={this.onPaste}
            style={style}
          />
        </label>

        <div className={`autosuggest-textarea__suggestions ${isSuggestionsHidden ? '' : 'autosuggest-textarea__suggestions--visible'}`}>
          {suggestions.map((suggestion, i) => (
            <div
              role='button'
              tabIndex='0'
              key={suggestion}
              data-index={suggestion}
              className={`autosuggest-textarea__suggestions__item ${i === selectedSuggestion ? 'selected' : ''}`}
              onMouseDown={this.onSuggestionClick}
            >
              <AutosuggestAccountContainer id={suggestion} />
            </div>
          ))}

          {emojiSuggestions.map((suggestion, i) => (
            <div
              role='button'
              tabIndex='0'
              key={i}
              data-index={i}
              className={`autosuggest-textarea__suggestions__item ${i === selectedSuggestion ? 'selected' : ''}`}
              onMouseDown={this.onProfileEmojiSuggestionClick}
            >
              <AutosuggestEmoji emoji={suggestion} />
            </div>
          ))}
        </div>
      </div>
    );
  }

}
