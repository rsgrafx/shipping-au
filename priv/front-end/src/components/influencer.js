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
    <li className="list-group-item">
      {prod.sku} - {prod.name}
    </li>
  )
}

const Influencer = ({profile, products}) => {
  const product_ids = profile.products.map((product) => (product.campaign_product_id))

  const _final = product_ids.map(
    (id) => (products.filter((p) => (p.campaign_product_id  === id)))
  )
  const assigned_products = [].concat(..._final)

  console.log(assigned_products)

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

    </div>
  )
}

export default Influencer;