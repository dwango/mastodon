import { connect } from 'react-redux';
import Announcements from '../components/announcements';
import { nicoruAnnouncement, toggleAnnouncements } from '../../../actions/announcements';

const mapStateToProps = (state) => ({
  nicotta: state.getIn(['announcements', 'nicotta']),
  visible: state.getIn(['announcements', 'visible']),
});

const mapDispatchToProps = (dispatch) => ({
  onNicoru (id) {
    dispatch(nicoruAnnouncement(id));
  },

  onToggle () {
    dispatch(toggleAnnouncements());
  },
});

export default connect(mapStateToProps, mapDispatchToProps)(Announcements);
