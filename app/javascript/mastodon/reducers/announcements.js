import Immutable from 'immutable';
import { NICORU_ANNOUNCEMENT, TOGGLE_ANNOUNCEMENTS } from '../actions/announcements';

const initialState = Immutable.Map({
  visible: true,
  nicotta: Immutable.List(),
});

export default function announcements(state = initialState, action) {
  switch(action.type) {
  case TOGGLE_ANNOUNCEMENTS:
    return state.set('visible', !state.get('visible'));
  case NICORU_ANNOUNCEMENT:
    return state.set('nicotta', state.get('nicotta').push(action.id));
  default:
    return state;
  }
};
