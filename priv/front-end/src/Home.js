import React, {Component} from 'react'
import Header from './components/Header.js'
import Button from './components/button.js'

class Home extends Component {

  state = {
    isHidden: false
  }

  handleClick = () => {
    this.setState(prevState => ({isHidden: !prevState.isHidden}))
  }

  render() {
    const {statement} = this.props;
    const {isHidden} = this.state;

    if (isHidden) {
      return(
        <div>
          <Button clickEvent={this.handleClick} title={'Hide or Show'}/>
          <Header />
          <p>{statement}</p>
        </div>
        );
    }

    return(
    <div>
      <Button clickEvent={this.handleClick} title={'Hide or Show'}/>
      <p>{statement}</p>
    </div>);
  }
}

export default Home