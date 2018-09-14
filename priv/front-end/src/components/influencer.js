import React from 'react'

import Address from './influencerDetails/address'
import PickingProduct from './influencerDetails/pickingProduct'
import SendleDetails from './influencerDetails/sendleDetails'
import ParcelDetailsBtn from './influencerDetails/parcelDetailsBtn'
import PackageDetailsForm from './influencerDetails/packageDetailsForm'

class Influencer extends React.Component {

  state = {
    showComponent: false
  }

  showFormContainer = () => {
    this.setState({showComponent: !this.state.showComponent}, () => console.log(this.state))
  }

  render() {
    const {profile, products, processed, updateParcelInfo} = this.props

    const product_ids = profile.products.map((product) => (product.campaign_product_id))

    const _final = product_ids.map(
      (id) => (products.filter((p) => (p.campaign_product_id  === id)))
    )
    const assigned_products = [].concat(..._final)

    return(
      <div className="panel panel-default text-left">
        <ParcelDetailsBtn
          alreadySent={processed}
          influencerId={profile.influencer_id}
          showFormContainer={this.showFormContainer}
          />
        <hr />
        <PackageDetailsForm
          influencerId={profile.influencer_id}
          showComponent={this.state.showComponent}
          updateParcelInfo={updateParcelInfo}
          />
        <div className="panel-heading">
          <div >
            <h4>{profile.full_name}</h4>
            <p>{profile.email}</p>
          </div>
          <Address address={profile.address} name={profile.full_name}/>
        </div>
        <div className="panel-body">
          <ul className="list-group">
            {
              assigned_products.map((product) => (<PickingProduct prod={product} />))
            }
          </ul>
        </div>

        <SendleDetails sendle_response={profile.sendle_response} />

      </div>
    )
  }
}

export default Influencer;