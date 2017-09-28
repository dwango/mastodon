import { connect }   from 'react-redux';
import ConnectAccount from '../components/connect_account';

const mapStateToProps = (state) => {
  return {
    nico_url: state.getIn(['meta', 'nico_url']),
  };
};

export default connect(mapStateToProps)(ConnectAccount);
