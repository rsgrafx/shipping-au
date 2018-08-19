# Sendle API

### Actors
* Admin (Someone in charge of putting together influencers and products)
* Packing Team Member (PTM) (?) Someone in charge of managing physically putting together packages.

#### (1)

 - (Admin) puts together approved Influencers have been selected for a campaign. Request is made to start a campaigns shipping process.

#### (2)

 - (PTM) Can see new campaigns (to be processed)

#### (3)
 - (PTM) uses dashboard to view picking list.

#### (4)
 - (PTM) uses dashboard to enter weight, shipping details for one or all packages for a specific campaign.
 - (PTM) received response with Order and Packing Slip details.

![simplified flow](https://s3.ap-south-1.amazonaws.com/utolending-media/final.mmd.png)

### Proposed Endpoints
- Given a campaign has a final list of `APPROVED` Influencers
- Sendle Service should receive a payload that contains campaign
participants and product matches.

### Required Headers for all endpoints

|key|value|
|-------------|-----|
|Content-Type| application/json|
|Accept|  application/json|


### POST /sendle/campaigns
* HTTP entry point into application.  UI will make request for influencer data to be processed.

#### Request Example
```json
{
	"data": {
		"campaign_id": 100,
		"campaign_name": "Lulumon Leggings Campaign Fall 2018",
		"notes" : "Missing some small tags",
		"participants": [{
				"influencer_id": 1001,
				"address": {
					"full_name": "Ms. Jane Doe",
					"address_line_1": "Level 1",
					"address_line_2": "17 Jones St",
					"city": "North Sydney",
					"state": "NSW",
					"country": "Australia",
					"postcode": "2060"
				},
				"products": [{
						"campaign_product_id": 101,
						"quantity": 2,
						"size": "12"
					},
					{
						"campaign_product_id": 102,
						"quantity": 1,
						"size": "3"
					}
				]
			},
			{
				"influencer_id": 1021,
				"address": {
					"full_name": "Ms. Satya Ramaputti",
					"address_line_1": "602 N May Mesa",
					"address_line_2": "Apt 82",
					"city": "Mesa",
					"state": "Arizona",
					"country": "USA",
					"postcode": "85201"
				},
				"products": [{
					"campaign_product_id": 101,
					"quantity": 2,
					"size": "12"
				}]
			},
			{
				"influencer_id": 3024,
				"address": {
					"full_name": "Losena Faluvau",
					"address_line_1": "Northern Press rd",
					"address_line_2": "Lot 11.",
					"city": "Nadi Town",
					"state": "",
					"country": "Fiji Islands",
					"postcode": ""
				},
				"products": [{
					"campaign_product_id": 101,
					"quantity": 2,
					"size": "4"
				}]
			},
			{
				"influencer_id": 3024,
				"address": {
					"full_name": "Mark Jamal",
					"address_line_1": "10 Eunos Road 8",
					"address_line_2": "",
					"city": "Singapore",
					"state": "",
					"country": "Republic of Singapore",
					"postcode": "408600"
				},
				"products": [{
					"campaign_product_id": 101,
					"quantity": 2,
					"size": "XL"
				}]
			}
		],
		"products": [{
				"campaign_product_id": 100,
				"name": "Metal Vent Tech Short Sleeve",
				"sku": "2034334"
			},
			{
				"campaign_product_id": 101,
				"name": "Align Pant Full Length 28",
				"sku": "3819211"
			},
			{
				"campaign_product_id": 102,
				"name": "Crafted Movement Bra - Girls",
				"sku": "3819008"
			}
		],
		"inserted_at": "<utc/datetime>",
		"shipment_process": "standard"
	}
}

```

#### Response Example
Status Code 202

```json
{
  "data" : {
    status: "accepted"
  }
}
```

### GET /sendle/campaigns/:campaign_id
* Fetch Picking list for an campaign which order has been started.  Data is surfaced in order to be used in a UI that can present a human readable Picking list.

##### Query Params
campaign_id = Campaign (id) in `Servalan`.

### Example Response (status = new || in_progress )
```json
{
	"data": {
		"status": "new", // <new, in_progress, complete>
		"campaign_id": 100,
		"campaign_name": "Lulumon Leggings Campaign Fall 2018",
		"notes": "Missing some small tags",
		"participants": [{
				"influencer_id": 1001,
				"address": {
					"full_name": "Ms. Jane Doe",
					"address_line_1": "Level 1",
					"address_line_2": "17 Jones St",
					"city": "North Sydney",
					"state": "NSW",
					"country": "Australia",
					"postcode": "2060"
				},
				"products": [{
						"campaign_product_id": 101,
						"quantity": 2,
						"size": "12"
					},
					{
						"campaign_product_id": 102,
						"quantity": 1,
						"size": "3"
					}
				]
			},
			{
				"influencer_id": 1021,
				"address": {
					"full_name": "Ms. Satya Ramaputti",
					"address_line_1": "602 N May Mesa",
					"address_line_2": "Apt 82",
					"city": "Mesa",
					"state": "Arizona",
					"country": "USA",
					"postcode": "85201"
				},
				"products": [{
					"campaign_product_id": 101,
					"quantity": 2,
					"size": "12"
				}]
			},
			{
				"influencer_id": 3024,
				"address": {
					"full_name": "Losena Faluvau",
					"address_line_1": "Northern Press rd",
					"address_line_2": "Lot 11.",
					"city": "Nadi Town",
					"state": "",
					"country": "Fiji Islands",
					"postcode": ""
				},
				"products": [{
					"campaign_product_id": 101,
					"quantity": 2,
					"size": "4"
				}]
			},
			{
				"influencer_id": 3024,
				"address": {
					"full_name": "Mark Jamal",
					"address_line_1": "10 Eunos Road 8",
					"address_line_2": "",
					"city": "Singapore",
					"state": "",
					"country": "Republic of Singapore",
					"postcode": "408600"
				},
				"products": [{
					"campaign_product_id": 101,
					"quantity": 2,
					"size": "XL"
				}]
			}
		],
		"products": [{
				"campaign_product_id": 100,
				"name": "Metal Vent Tech Short Sleeve",
				"sku": "2034334"
			},
			{
				"campaign_product_id": 101,
				"name": "Align Pant Full Length 28",
				"sku": "3819211"
			},
			{
				"campaign_product_id": 102,
				"name": "Crafted Movement Bra - Girls",
				"sku": "3819008"
			}
		],
		"inserted_at": "<utc/datetime>",
		"shipment_process": "standard",
		"packing_slips": null  // will be populated when status complete.
	}
}
```

### POST /sendle/campaigns/:campaign_id/process
* (Picking List UI) - will post package details to endpoint.

#### Example Request
```json
{
	"data": {
		"participants": [{
				"influencer_id": 1001,
				"campaign_id": 100,
				"package": {
					"pickup_date": "2015-11-24",
					"description": "Product details from from Vamp client",
					"kilogram_weight": "1",
					"cubic_metre_volume": "0.01",
					"customer_reference": "SupBdayPressie",
					"metadata": {
						"your_data": "XYZ123"
					}
				}
			},
			{
				"influencer_id": 1012,
				"campaign_id": 100,
				"package": {
					"pickup_date": "2015-11-24",
					"description": "Product details from from Vamp client",
					"kilogram_weight": "1",
					"cubic_metre_volume": "0.01",
					"customer_reference": "SupBdayPressie",
					"metadata": {
						"your_data": "XYZ123"
					}
				}
			}

		]
	}
}
```

#### Example Response (complete)
Status code 200
```json
{
	"data": {
		"status": "complete",
		"campaign_id": 100,
		"campaign_name": "Lulumon Leggings Campaign Fall 2018",
		"notes": "Missing some small tags",
		"participants": [{
				"influencer_id": 1001,
				"address": {
					"full_name": "Ms. Jane Doe",
					"address_line_1": "Level 1",
					"address_line_2": "17 Jones St",
					"city": "North Sydney",
					"state": "NSW",
					"country": "Australia",
					"postcode": "2060"
				},
				"products": [{
						"campaign_product_id": 101,
						"quantity": 2,
						"size": "12"
					},
					{
						"campaign_product_id": 102,
						"quantity": 1,
						"size": "3"
					}
				]
			},
			{
				"influencer_id": 1021,
				"address": {
					"full_name": "Ms. Satya Ramaputti",
					"address_line_1": "602 N May Mesa",
					"address_line_2": "Apt 82",
					"city": "Mesa",
					"state": "Arizona",
					"country": "USA",
					"postcode": "85201"
				},
				"products": [{
					"campaign_product_id": 101,
					"quantity": 2,
					"size": "12"
				}]
			},
			{
				"influencer_id": 3024,
				"address": {
					"full_name": "Losena Faluvau",
					"address_line_1": "Northern Press rd",
					"address_line_2": "Lot 11.",
					"city": "Nadi Town",
					"state": "",
					"country": "Fiji Islands",
					"postcode": ""
				},
				"products": [{
					"campaign_product_id": 101,
					"quantity": 2,
					"size": "4"
				}]
			},
			{
				"influencer_id": 3024,
				"address": {
					"full_name": "Mark Jamal",
					"address_line_1": "10 Eunos Road 8",
					"address_line_2": "",
					"city": "Singapore",
					"state": "",
					"country": "Republic of Singapore",
					"postcode": "408600"
				},
				"products": [{
					"campaign_product_id": 101,
					"quantity": 2,
					"size": "XL"
				}]
			}
		],
		"products": [{
				"campaign_product_id": 100,
				"name": "Metal Vent Tech Short Sleeve",
				"sku": "2034334"
			},
			{
				"campaign_product_id": 101,
				"name": "Align Pant Full Length 28",
				"sku": "3819211"
			},
			{
				"campaign_product_id": 102,
				"name": "Crafted Movement Bra - Girls",
				"sku": "3819008"
			}
		],
		"inserted_at": "<utc/datetime>",
		"shipment_process": "standard",
		"packing_slips": [{
				"influencer_id": 1001,
				"sendle": {
					"sendle_reference": "A3ND2MM",
					"cost": 20.00,
					"order_uuid": "sendle-uuid",
					"order_packing_slip": "http://sendleapi.url.to.pdf",
					"tracking_url":"https://track.sendle.com/tracking?ref=A3ND2MM"
				},
				"address": {
					"full_name": "Ms. Jane Doe",
					"address_line_1": "Level 1",
					"address_line_2": "17 Jones St",
					"city": "North Sydney",
					"state": "NSW",
					"country": "Australia",
					"postcode": "2060"
				}
			},
			{
				"influencer_id": 1021,
				"sendle": {
					"sendle_reference": "S3ND73",
					"cost": 30.40,
					"order_uuid": "sendle-uuid",
					"order_packing_slip": "http://sendleapi.url.to.pdf",
					"tracking_url":"https://track.sendle.com/tracking?ref=S3ND73"
				},
				"address": {
					"full_name": "Ms. Satya Ramaputti",
					"address_line_1": "602 N May Mesa",
					"address_line_2": "Apt 82",
					"city": "Mesa",
					"state": "Arizona",
					"country": "USA",
					"postcode": "85201"
				}
			}
		]
	}
}
```
