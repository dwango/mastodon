import { connect } from 'react-redux';
import EnqueteInputs from '../components/enquete_inputs';
import { changeComposeEnqueteText } from '../../../actions/enquetes';
import { submitCompose } from '../../../actions/compose';

const mapStateToProps = state => ({
  active: state.getIn(['enquetes', 'active']),
  items:  state.getIn(['enquetes', 'items']),
});

const mapDispatchToProps = dispatch => ({
  onChangeEnqueteText(text, index){
    dispatch(changeComposeEnqueteText(text, index));
  },

  onSubmit() {
    dispatch(submitCompose());
  },
});

export default connect(mapStateToProps, mapDispatchToProps)(EnqueteInputs);
