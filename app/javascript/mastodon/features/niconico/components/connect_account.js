import React from 'react';
import ImmutablePropTypes from 'react-immutable-proptypes';

class ConnectAccount extends React.PureComponent {

  render() {
    const { account } = this.props;

    if (!account) {
      return <div />;
    }

    const nico_url = account.get('nico_url');
    const connectLink = nico_url !== null ? (
      <a
         href={nico_url}
         target='_blank'
         rel='noopener'
      >
        <span className='nico-connect-account__label'>
          niconicoアカウントと連携済み
        </span>
      </a>
    ) : (
      <a
         className='nico-connect-account__wrapper'
         href='/auth/auth/niconico'
      >
        <span className='nico-connect-account__label nico-connect-account__label--disabled'>
          niconicoアカウントと連携する
        </span>
      </a>
    );

    return (
      <div className='nico-connect-account'>
        {connectLink}
      </div>
    );
  }

}

ConnectAccount.propTypes = {
  account: ImmutablePropTypes.map.isRequired,
};

export default ConnectAccount;
