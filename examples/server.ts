import { faker } from 'https://cdn.skypack.dev/@faker-js/faker'
// @deno-types="npm:@types/express@4"
import express, { Request, Response } from "npm:express@4.18.2"

const app = express()
const port = Number(Deno.env.get("PORT")) || 4000
const host = Deno.env.get("HOST") || '0.0.0.0'
const timeout = Number(Deno.env.get("TIMEOUT")) || 2000


app.get('/', (_req: Request, res: Response) => {
  res.json('Savoir Fake API')
})

// Route with paginated results.
app.get('/users', async (req: Request, res: Response) => {
  await new Promise(r => setTimeout(r, timeout))
  // const page = req.query.page || 0
  const per_page = req.query.per_page || 20
  res.json({
    total: faker.number.int({ min: per_page, max: 1000 }),
    items: faker.helpers.multiple(() => ({
      id: faker.string.uuid(),
      first_name: faker.person.firstName(),
      last_name: faker.person.lastName(),
      email: faker.internet.email(),
      job: faker.person.jobTitle(),
      bio: faker.person.bio()
    }), { count: Number(per_page) })
  })
})

// Route with progressive loading.
app.get('/reservations', async (req: express.Request, res: express.Response) => {
  await new Promise(r => setTimeout(r, timeout))
  const per_page = req.query.per_page || 20
  // const index = req.query.index || 0
  res.json({
    index: faker.number.int(),
    items: faker.helpers.multiple(() => ({
      id: faker.string.uuid(),
      airline: faker.airline.airline(),
      airplane: faker.airline.airplane(),
      number: faker.airline.flightNumber(),
      seat: faker.airline.seat()
    }), { count: per_page })
  })
})

app.listen(port, host, () => {
  console.log(`Listening on ${host}:${port} ...`)
})
