import { connect } from 'react-redux';
import Player from '../components/player';
import { openNiconicoVideoLink, toggleNiconicoVideoPlayer, updateNiconicoVideoInput, onNicovideoShare } from '../../../../actions/nicovideo_player';

const mapStateToProps = (state) => ({
  visible: state.getIn(['settings', 'friends', 'videoplayer']),
  videoId: state.getIn(['nicovideo_player', 'videoId']),
  input: state.getIn(['nicovideo_player', 'input']),
});

const mapDispatchToProps = (dispatch) => ({

  onToggle() {
    dispatch(toggleNiconicoVideoPlayer());
  },

  onNicovideoShare(videoId) {
    dispatch(onNicovideoShare(videoId));
  },

  onNicovideoPlay(videoId) {
    dispatch(openNiconicoVideoLink(videoId));
  },

  onChangeVideoId(videoId) {
    dispatch(updateNiconicoVideoInput(videoId));
  },

});

export default connect(mapStateToProps, mapDispatchToProps)(Player);
