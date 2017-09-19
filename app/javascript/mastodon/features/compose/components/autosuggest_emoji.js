import React from 'react';
import Avatar from '../../../components/avatar';
import ImmutablePropTypes from 'react-immutable-proptypes';
import ImmutablePureComponent from 'react-immutable-pure-component';

export default class AutosuggestEmoji extends ImmutablePureComponent {

  static propTypes = {
    emoji: ImmutablePropTypes.map.isRequired,
  };

  render () {
    const { emoji } = this.props;

    return (
      <div className='autosuggest-account'>
        <div className='autosuggest-account-icon'><Avatar src={emoji.get('original_url')} staticSrc={emoji.get('url')} size={18} /></div>
        {emoji.get('shortcode')}
      </div>
    );
  }

}
