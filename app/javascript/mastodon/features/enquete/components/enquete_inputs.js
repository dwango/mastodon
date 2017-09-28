import React from 'react';
import PropTypes from 'prop-types';
import { defineMessages, injectIntl } from 'react-intl';
import Collapsable from '../../../components/collapsable';
import ImmutablePureComponent from 'react-immutable-pure-component';
import ImmutablePropTypes from 'react-immutable-proptypes';

const messages = defineMessages({
  0: { id: 'enquete_input.item_1', defaultMessage: 'item1' },
  1: { id: 'enquete_input.item_2', defaultMessage: 'item2' },
  2: { id: 'enquete_input.item_3', defaultMessage: 'item3(option)' },
  3: { id: 'enquete_input.item_4', defaultMessage: 'item4(option)' },
});

@injectIntl
export default class EnqueteInputs extends ImmutablePureComponent {

  static propTypes = {
    active: PropTypes.bool.isRequired,
    items: ImmutablePropTypes.list.isRequired,
    intl: PropTypes.object.isRequired,
    onChangeEnqueteText: PropTypes.func.isRequired,
  };
  handleChangeEnqueteText = (e) => {
    const enquete_item_index = e.target.getAttribute('id').split('-')[2];
    this.props.onChangeEnqueteText(e.target.value, enquete_item_index);
  }

  handleKeyDown = (e) => {
    if (e.keyCode === 13 && (e.ctrlKey || e.metaKey)) {
      this.props.onSubmit();
    }
  }

  render() {
    const { active, items, intl } = this.props;
    const inputMaxLength = 15;
    return (
      <Collapsable isVisible={active} fullHeight={158}>
        {[0, 1, 2, 3].map(index => (
          <div className='enquete-input' key={`enquete-input-${index}`}>
            <input
               type='text'
               id={`enquete-input-${index}`}
               className='enquete-input__input'
               placeholder={intl.formatMessage(messages[index])}
               value={items.get(index)}
               onChange={this.handleChangeEnqueteText}
               onKeyDown={this.handleKeyDown}
               maxLength={inputMaxLength}
            />
          </div>
        ))}
      </Collapsable>);
  }

}
