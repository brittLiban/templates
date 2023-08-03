import {
  InteractionResponseType,
  InteractionType,
  verifyKey,
} from 'discord-interactions';
import { throwIfMissing } from './utils.js';

export default async ({ req, res, error, log }) => {
  throwIfMissing(process.env, [
    'DISCORD_PUBLIC_KEY',
    'DISCORD_APPLICATION_ID',
    'DISCORD_TOKEN',
  ]);

  log(req.bodyRaw);

  const verified = await verifyKey(
    req.bodyRaw,
    req.headers['x-signature-ed25519'],
    req.headers['x-signature-timestamp'],
    process.env.DISCORD_PUBLIC_KEY
  );

  if (!verified) {
    error('Invalid request.');
    return res.json({ error: 'Invalid request signature' }, 401);
  }

  log('Valid request');

  const interaction = req.body;
  if (
    interaction.type === InteractionType.APPLICATION_COMMAND &&
    interaction.data.name === 'hello'
  ) {
    log('Matched hello command - returning message');

    const response = {
      type: InteractionResponseType.CHANNEL_MESSAGE_WITH_SOURCE,
      data: {
        content: 'Hello, World!',
      },
    };

    log(JSON.stringify(response));
    log(JSON.stringify(res.json(response)));
    return res.json(response);
  }

  log("Didn't match any known interaction - returning PONG");

  return res.json({ type: InteractionResponseType.PONG });
};
