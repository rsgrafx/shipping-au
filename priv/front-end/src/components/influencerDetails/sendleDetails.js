import React from 'react'

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

export default SendleDetails;