import React from 'react'
import PickingLists from './components/pickingList.js'

const Home = ({lists}) => {
  return(
    <div>
      <PickingLists lists={lists} />
    </div>
  )
}

export default Home