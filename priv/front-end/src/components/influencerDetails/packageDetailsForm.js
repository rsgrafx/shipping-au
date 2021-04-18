import React from 'react'

export default class PackageDetailsForm extends React.Component {

  state = {
    influencerId: this.props.influencerId,
    description: "AcmeCo product campaign",
		pickup_date: null,
		kilogram_weight: "1",
		cubic_metre_volume: "0.01",
    customer_reference: null,
    contents: {
      description: null,
      value: 0,
      country_of_origin: null
    }
  }

  render() {
    const {showComponent} = this.props
    const {description, influencerId} = this.state

    if (showComponent === false)
      return null;

      return(
        <div className="form-popup">
          <form className="form-container">
            <h5>Influencer ID: {influencerId} </h5>
            <label>Description</label>
            <input type="text" placeholder={description} />
            <div className="input-item">
              <label for="pickupDate"><b>Pickup Date</b></label><br />
              <input type="date" placeholder="SelectDate" name="email" /><br />
            </div>
            <div className="input-item">
              <label for="kilogram_weight"><b>Weight KG</b></label><br />
              <input type="number"/><br />
            </div>
            <div className="input-item">
              <label for="volume">Cubic Meter volume</label><br />
              <input type="number"/><br />
            </div>
            <button type="submit" className="btn btn-small btn-block">Submit</button>
          </form>
        </div>
    )
  }
}