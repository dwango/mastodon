import React from 'react';
import ImmutablePropTypes from 'react-immutable-proptypes';
import ImmutablePureComponent from 'react-immutable-pure-component';

class AccountButton extends ImmutablePureComponent {

  static propTypes = {
    account: ImmutablePropTypes.map.isRequired,
  };

  render() {
    const { account } = this.props;

    if (!account) {
      return null;
    }

    const nicoUrl = account.get('nico_url');

    if (nicoUrl === null) {
      return null;
    }

    return (
      <div className='nico-account-button'>
        <a
          href={nicoUrl}
          target='_blank'
          rel='noopener'
        >
          <i className='nico-account-button__icon' />
        </a>
      </div>
    );
  }

}

export default AccountButton;
