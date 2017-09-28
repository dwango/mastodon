import React from 'react';
import PropTypes from 'prop-types';

export default class AdminAnnouncements extends React.PureComponent {

  static propTypes = {
    settings: PropTypes.string,
  };

  render () {
    const { settings } = this.props;

    if (settings.length === 0) {
      return null;
    }

    return (
      <div
         className='announcements__admin'
         dangerouslySetInnerHTML={{ __html: settings }}
      />
    );
  }

};
