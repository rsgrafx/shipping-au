import React from 'react'

import * as sendleApi from './sendleApi.js'
import Address from './components/influencerDetails/address.js'

import addressData from './mockAddresses.js'

const Name = ({name}) => {
  const {title, first, last} = name
  return(
    <div>
      <h4>{title}. {first} {last}</h4>
    </div>
  )
}

const MockUser = ({
    user: {
      picture,
      name,
      email,
      address
    }
  }) => {
  return(
    <div className="mockUser col-md-6">
      <div className="col-md-4">
        <img src={picture.large} alt={`${name.first}}`} />
        <p>{email}</p>
      </div>
      <div className="col-md-8">
        <Name name={name} />
        <Address address={address} name={`${name.first} ${name.last}`} />
      </div>
      <hr />
    </div>
  )
}

export default class MockCampaign extends React.Component {

  state = {
    users: []
  }

  componentDidMount() {
    const {addresses} = addressData
    const users = sendleApi.getMockUsers()
      .then((users) => {
        let userAddresses = users.results.map((user, index) => Object.assign(user, {address: addresses[index]}))
        this.setState({users: userAddresses})
        }
      )
  }

  render() {
    const {users} = this.state
    return(
      <div className="text-left">
        <div>
          <button className="btn-primary btn pull-right">Begin Fullfillment Process</button>
          <h1>Addidas Campaign</h1>
          <h3>Mock Campaign with preselected Influencers</h3>
        </div>
        {users !== [] && users.map((randomUser) => <MockUser user={randomUser} />)}
      </div>
    )
  }
}