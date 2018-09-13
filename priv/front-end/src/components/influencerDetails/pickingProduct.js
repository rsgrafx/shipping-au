import React from 'react'

const PickingProduct = ({prod}) => {
  return (
    <li className=" panel-body list-group-item">
      <span className="col-md-3">Product Sku: {prod.sku}</span>
      <span className="col-md-6">Name: {prod.name}</span>
    </li>
  )
}

export default PickingProduct;