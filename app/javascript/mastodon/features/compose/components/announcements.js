import React from 'react';
import Immutable from 'immutable';
import PropTypes from 'prop-types';
import ImmutablePropTypes from 'react-immutable-proptypes';
import IconButton from '../../../components/icon_button';

const announcements = Immutable.fromJS([
  {
    id: 1,
    body: 'friends.nico のアプリができました!',
    links: [
      {
        href: 'https://itunes.apple.com/jp/app/friends-nico/id1230158182?l=ja&ls=1&mt=8',
        body: 'iOS版',
      },
      {
        href: 'https://play.google.com/store/apps/details?id=nico.friends.android',
        body: 'Android版',
      },
    ],
    nicotta: false,
  },
  {
    id: 2,
    body: '利用時のお困りごとなどは @friends_nico へ Mention か DM でご連絡ください',
    links: [],
    nicotta: false,
  },
]);

export default class Announcements extends React.PureComponent {

  static propTypes = {
    nicotta: ImmutablePropTypes.list.isRequired,
    visible: PropTypes.bool.isRequired,
    onNicoru: PropTypes.func.isRequired,
    onToggle: PropTypes.func.isRequired,
  }

  handleNicoru (id) {
    return () => {
      this.props.onNicoru(id);
    };
  }

  render () {
    const { visible, nicotta, onToggle } = this.props;
    const caretClass = visible ? 'fa fa-caret-down' : 'fa fa-caret-up';
    return (
      <div className='announcements'>
        <div className='compose__extra__header'>
          <i className='fa fa-bell' />
          お知らせ
          <button className='compose__extra__header__icon' onClick={onToggle} >
            <i className={caretClass} />
          </button>
        </div>
        { visible && (
          <ul>
            {announcements.map((announcement, idx) => (
              <li key={idx}>
                <div className='announcements__icon'>
                  <IconButton
                     active={nicotta.includes(announcement.get('id'))}
                     animate
                     icon='nicoru--status'
                     title='announcement-icon'
                     onClick={this.handleNicoru(announcement.get('id'))}
                    activeStyle={{ color: '#ca8f04' }}
                  />
                </div>
                <div className='announcements__body'>
                  <p>{announcement.get('body')}</p>
                  <div className='links'>
                    {announcement.get('links').map((link, i) => (
                      <a href={link.get('href')} target='_blank' key={i}>
                        {link.get('body')}
                      </a>
                    ))}
                  </div>
                </div>
              </li>
            ))}
          </ul>
        )}
      </div>
    );
  }

}
