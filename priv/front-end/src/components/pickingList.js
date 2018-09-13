import React, {Component} from 'react'
import {Link} from 'react-router-dom'

const PickingList = ({data}) => {
  return(
    <li className="list-group-item">
      <Link to={`/pickingList/${data.campaign_id}`}><h3>{data.campaign_name}</h3> </Link>
    </li>
  )
}

const PackingList = ({data}) => {
  return(
    <li className="list-group-item">
      <Link to={`/packingList/${data.campaign_id}`}><h3>{data.campaign_name}</h3> </Link>
    </li>
  )
}

export default class PickingLists extends Component {

  render() {
    const {lists} = this.props
    return(
      <div className="text-left">
        <div className="panel panel-default">
          <div className="panel-header">
            <h3>Current Picking Lists</h3>
          </div>
          <div className="panel-body">
            <ul className="list-group">
            { lists.pickingLists !== undefined
              && lists.pickingLists.map((pickingList) => (<PickingList data={pickingList}/>))}
            </ul>
          </div>
        </div>

       <div className="panel panel-default">
          <div className="panel-header">
            <h3>Completed Packing Orders</h3>
          </div>
          <div className="panel-body">
            <ul className="list-group">
            { lists.packingLists !== undefined
              && lists.packingLists.map((pickingList) => (<PackingList data={pickingList}/>))}
            </ul>
          </div>
        </div>
      </div>
    )
  }
}