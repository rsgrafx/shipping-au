import React from 'react'

class ParcelDetailsBtn extends React.Component {

  render() {
    const {alreadySent, showFormContainer} = this.props
    if (alreadySent) {
      return null;
    } else {
      return(
        <div className="parcel-btn pull-left btn-primary">
          <button onClick={showFormContainer} className="btn btn-large btn-primary"> Enter Parcel Details</button>
        </div>
      )
    }
  }
}

export default ParcelDetailsBtn;