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

export default Address;