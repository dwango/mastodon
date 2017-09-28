import React from 'react';
import PropTypes from 'prop-types';
import ImmutablePureComponent from 'react-immutable-pure-component';

class ConnectAccount extends ImmutablePureComponent {

  static propTypes = {
    nico_url: PropTypes.string,
  };

  connectedLink(nico_url) {
    return (
      <a
         href={nico_url}
         target='_blank'
         rel='noopener'
      >
        <span className='nico-connect-account__label'>
          niconicoアカウントと連携済み
        </span>
      </a>
    );
  }

  connectLink() {
    return (
      <a
         className='nico-connect-account__wrapper'
         href='/auth/auth/niconico'
      >
        <span className='nico-connect-account__label nico-connect-account__label--disabled'>
          niconicoアカウントと連携する
        </span>
      </a>
    );
  }

  render() {
    const { nico_url } = this.props;
    return (
      <div className='nico-connect-account'>
        {nico_url ? this.connectedLink(nico_url) : this.connectLink()}
      </div>
    );
  }

}

export default ConnectAccount;
