import React from 'react';
import Immutable from 'immutable';
import IconButton from '../../../components/icon_button';

const announcements = Immutable.fromJS([
  {
    id: 1,
    body: 'friends.nico の iOSアプリができました!',
    link: {
      href: 'https://itunes.apple.com/jp/app/friends-nico/id1230158182?l=ja&ls=1&mt=8',
      body: 'App Storeへ',
    },
    nicotta: false,
  },
]);

const Announcements = React.createClass({
  getInitialState () {
    return { nicotta: [] };
  },
  handleNicoru (id) {
    return e => {
      if (this.state.nicotta.includes(id))
        return ;
      this.setState({ nicotta: [].concat(this.state.nicotta, id) });
    };
  },

  render () {
    const { nicotta } = this.state;
    return (
      <ul className='announcements'>
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
              {announcement.get('link') && (
                <a href={announcement.getIn(['link', 'href'])} target='_blank'>
                  {announcement.getIn(['link', 'body'])}
                </a>
              )}
            </div>
          </li>
        ))}
      </ul>
    );
  },
});

export default Announcements;
