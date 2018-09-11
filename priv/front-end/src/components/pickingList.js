import React, {Component} from 'react'
import {Link} from 'react-router-dom'

const PickingList = ({data}) => {
  return(
    <li className="list-group-item">
      <Link to={`/pickingList/${data.campaign_id}`}><h3>{data.campaign_name}</h3> </Link>
    </li>
  )
}

export default class PickingLists extends Component {

  render() {
    const {lists} = this.props
    return(
      <div className="col-md-12 text-left">
        <div className="panel panel-default">
          <h3>Current Picking Lists</h3>
        </div>
        <div className="panel-body">
          <ul className="list-group">
          { lists !== undefined && lists.map((pickingList) => (<PickingList data={pickingList}/>))}
          </ul>
        </div>
      </div>
    )
  }
}