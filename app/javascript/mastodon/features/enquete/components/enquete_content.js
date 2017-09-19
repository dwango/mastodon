import React from 'react';
import ImmutablePropTypes from 'react-immutable-proptypes';
import PropTypes from 'prop-types';
import emojify from '../../../emoji';
import Immutable from 'immutable';

export default class EnqueteContent extends React.PureComponent {

  static contextTypes = {
    router: PropTypes.object,
  };

  static propTypes = {
    status: ImmutablePropTypes.map.isRequired,
    onVote: PropTypes.func,
    onVoteLoad: PropTypes.func,
    onEnqueteTimeout: PropTypes.func,
  };

  componentWillMount() {
    const { status } = this.props;

    const createdAt = Date.parse(status.get('created_at'));
    const id = status.get('id');
    const enquete = Immutable.fromJS(JSON.parse(status.get('enquete')));

    if (enquete.get('type') === 'enquete_result') {
      this.setState({ alive: false });
    } else {
      const isAlreadyVoted = this.readVoteHistory(id);
      if (isAlreadyVoted !== null) {
        this.props.onVoteLoad(id, isAlreadyVoted);
      }
      if (Date.now() - createdAt > 30 * 1000) {
        //already dead enquete when rendered
        this.props.onEnqueteTimeout(id);
        this.setState({
          alive: false,
          timeCreated: createdAt,
          timeRemaining: -1,
        });
      } else {
        //still alive enquete
        this.setState({
          alive: true,
          timeCreated: createdAt,
          timeRemaining: 30,
        });
      }
    }

    const profileEmojiMap = status.get('profile_emojis', []).reduce((obj, emoji) => {
      obj[emoji.get('shortcode')] = emoji.toJSON();
      return obj;
    }, {});
    this.setState({ profileEmojiMap });
  };

  readVoteHistory(id) {
    let result = null;

    const cookieName = 'vote_to_' + String(id) + '=';
    const allCookies = document.cookie;
    const position = allCookies.indexOf(cookieName);
    if (position !== -1) {
      var startIndex = position + cookieName.length;
      var endIndex   = allCookies.indexOf(';', startIndex);
      if (endIndex === -1) {
        endIndex = allCookies.length;
      }
      result = allCookies.substring(startIndex, endIndex);
    }
    return result;
  }

  tick() {
    const tr = 30 - (Date.now() - this.state.timeCreated) / 1000;
    if (tr < 0) {
      clearInterval(this.interval);
      this.setState({ timeRemaining: -1 });
      this.props.onEnqueteTimeout(this.props.status.get('id'));
    } else {
      this.setState({ timeRemaining: tr.toFixed(2) });
    }
  };

  componentDidMount() {
    if (this.state.alive) {
      this.interval = setInterval(this.tick.bind(this), 30);
    }
  };

  componentWillUnmount() {
    clearInterval(this.interval);
  };

  // call onVote
  handleEnqueteButtonClick = (e) => {
    const index = e.currentTarget.getAttribute('data-number');
    this.props.onVote(this.props.status.get('id'), index);
  }

  render() {
    const { status } = this.props;
    const { profileEmojiMap } = this.state;
    const enquete = Immutable.fromJS(JSON.parse(status.get('enquete')));
    const questionContent = { __html: emojify(enquete.get('question'), profileEmojiMap) };

    const itemsContent = enquete.get('type') === 'enquete' ?
            this.voteContent(status, enquete, profileEmojiMap) : this.resultContent(enquete, profileEmojiMap);

    return (
      <div className='enquete-form'>
        <div className='enquete-question' dangerouslySetInnerHTML={questionContent} />
        { itemsContent }
      </div>
    );
  }

  voteContent(status, enquete, profileEmojiMap) {
    const enable = !(status.get('vote') || status.get('enquete_timeout'));
    const voted = parseInt(status.get('voted_num'), 10);
    const gauge = this.gaugeContent(status);
    const itemClassName = (index) => {
      const base = 'enquete-button';
      if (enable)
        return `${base} active`;
      if (index === voted)
        return `${base} disable__voted`;
      return `${base} disable`;
    };

    return (
      <div className='enquete-vote-items'>
        {enquete.get('items').filter(item => item !== '').map((item, index) => {
          const itemHTML = { __html: emojify(item, profileEmojiMap) };
          return (
            <button
               key={index}
               className={itemClassName(index)}
               dangerouslySetInnerHTML={itemHTML}
               onClick={enable ? this.handleEnqueteButtonClick : null}
               data-number={index}
            />);
        })}
        {gauge}
      </div>
    );
  }

  resultContent(enquete, profileEmojiMap) {
    return (
      <div className='enquete-result-items'>
        {enquete.get('items').filter(item => item !== '').map((item, index) => {
          // ratios is not immutable component
          const itemRatio = (enquete.get('ratios')).get(index) + '%';
          const itemRatioText = enquete.get('ratios_text').get(index);
          const itemRatioHTML = { __html: emojify(itemRatioText, profileEmojiMap) };
          const itemHTML = { __html: emojify(item, profileEmojiMap) };
          const resultGaugeClassName = 'item-gauge__inner';
          return (
            <div className='enquete-result-item-gauge' key={index} >
              <div className='item-gauge__content'>
                <div className='item-gauge__text__wrapper'>
                  <span className='item-gauge__text' dangerouslySetInnerHTML={itemHTML} />
                </div>
                <div className='item-gauge__ratio__wrapper'>
                  <span className='item-gauge__ratio' dangerouslySetInnerHTML={itemRatioHTML} />
                </div>
              </div>
              <div className='item-gauge__outer' style={{ width: '100%' }} />
              <div className={resultGaugeClassName} style={{ width: itemRatio }} />
            </div>);
        })}
      </div>
    );
  }

  gaugeContent(status) {
    const { timeRemaining } = this.state;
    const gauge_width = {
      width: String((30 - timeRemaining) / 30 * 100) + '%',
    };

    return (
      <div className='enquete-deadline'>
        <div className='enquete-gauge'>
          <div className='enquete-gauge-outer'>
            <div className='enquete-gauge-inner' style={gauge_width}>
              <i className='tv-chan nico-account-button__icon' />
            </div>
          </div>
        </div>
        <div className='enquete-time'>
          {status.get('enquete_timeout') ? '終了' : timeRemaining}
        </div>
      </div>
    );
  }

}
