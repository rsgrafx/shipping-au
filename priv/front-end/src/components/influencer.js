import React from 'react'

const Address = ({address, name}) => {
  return(
    <div>
      <address>
        <strong>{name}</strong><br/>
        {address.address_line1}<br/>
        {address.address_line2}<br/>
        {address.city}<br/>
        {address.country} {address.postcode}<br/>
        <br/>
        {/* <abbr title="Phone">P:</abbr> (123) 456-7890 */}
      </address>
    </div>
  )
}

const PickingProduct = ({prod}) => {
  return (
    <li className=" panel-body list-group-item">
      <span className="col-md-3">Product Sku: {prod.sku}</span>
      <span className="col-md-6">Name: {prod.name}</span>
    </li>
  )
}

const SendleDetails = ({sendle_response}) => {

  if (sendle_response.tracking_url) {
    const {tax, net, gross} = sendle_response.price
    return(
    <div className="panel-body">
      <h4>Sendle Order Id: {sendle_response.order_id}</h4>
      <p>
        <h4>Download Labels</h4>
        <label className="text-danger">Be sure to have login info - will be need to enter (login to download) via basic auth. </label><br />
        <a href={`${sendle_response.order_url}/labels/a4.pdf`} target="_blank">Full</a>  <br />
        <a href={`${sendle_response.order_url}/labels/cropped.pdf`} target="_blank">Cropped</a>
      </p>
      <ul className="list-group">
        <li className="list-group-item">tax: {tax.currency} - ${tax.amount}</li>
        <li className="list-group-item">Net: {net.currency} - ${net.amount}</li>
        <li className="list-group-item">Gross: {gross.currency} - ${gross.amount}</li>
      </ul>
      <p>
        <b>Trackig Url: </b> {sendle_response.tracking_url} <br/>
        <b>Order Url:</b> {sendle_response.order_url} <br />
      </p>
    </div>)
  } else {
    return null;
  }

}

const Influencer = ({profile, products}) => {
  const product_ids = profile.products.map((product) => (product.campaign_product_id))

  const _final = product_ids.map(
    (id) => (products.filter((p) => (p.campaign_product_id  === id)))
  )
  const assigned_products = [].concat(..._final)

  return(
    <div className="panel panel-default text-left">
      <div className="panel-heading">
        <div>
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

export default Influencer;