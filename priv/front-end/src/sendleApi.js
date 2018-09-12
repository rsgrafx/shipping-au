// Basic interface to call into API.
const api = process.env.REACT_APP_API_ENDPOINT

const headers = {
  'Accept' : 'application/json',
  'Content-Type': 'application/json'
}

export const getAllPickingLists = () =>
  fetch(`${api}/sendle/pickinglists`, {
      method: 'GET',
      ...headers
    })
    .then(res => res.json())
    .then(data => data)

export const get = (campaign_id) =>
   fetch(`${api}/sendle/campaigns/${campaign_id}`, {
     method: 'GET',
     ...headers
   })
   .then(response => response.json())
   .then(data => data)

export const getPackingLists = () =>
   fetch(`${api}/sendle/packinglists`, {
    method: 'GET', ...headers
   })
   .then(res => res.json())
   .then(data => data)