import React from 'react'
import {Link} from 'react-router-dom'
import PickingLists from './components/pickingList.js'

const Home = ({lists}) => {
  return(
    <div>
      <Link to="/mockCampaign">Show mock Campaign</Link>
      <PickingLists lists={lists} />
    </div>
  )
}

export default Home