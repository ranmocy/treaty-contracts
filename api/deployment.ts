import axios from 'axios';
import { GameConfig } from 'curio-vault/src/types/deployment';

const api = axios.create();
api.defaults.baseURL = process.env.BACKEND_URL;

export const publishDeployment = async (gameConfig: GameConfig) => {
  try {
    const { data } = await api.post(`/deployments/add`, gameConfig);

    if (data && data.status === 'success') {
      console.log('✦ Published successfully');
    } else {
      throw new Error('✦ Published unsuccessfully');
    }
  } catch (err) {
    console.log(err);
  }
};

export const isConnectionLive = async (): Promise<boolean> => {
  try {
    const { data } = await api.get(`/check`);
    return data.status === 'success';
  } catch (err: any) {
    throw new Error(err.message);
  }
};

export const startGameSync = async (deployment: GameConfig): Promise<void> => {
  try {
    const indexerApi = axios.create({ baseURL: deployment.indexerUrl });

    const { data } = await indexerApi.post(`/startGameSync`, { deploymentId: deployment.deploymentId });
  } catch (err: any) {
    throw new Error(err.message);
  }
};
