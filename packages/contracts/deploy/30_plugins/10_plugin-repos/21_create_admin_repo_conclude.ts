import {DeployFunction} from 'hardhat-deploy/types';
import {
  PluginRepoFactory__factory,
  PluginRepo__factory,
} from '../../../typechain';
import {EHRE} from '../../../utils/types';

const func: DeployFunction = async function (hre: EHRE) {
  console.log(`Concluding TokenVotingSetup deployment.\n`);
  const [deployer] = await hre.ethers.getSigners();

  const {deployments} = hre;

  const PluginRepoFactoryDeployment = await deployments.get(
    'PluginRepoFactory'
  );
  const pluginRepoFactory = PluginRepoFactory__factory.connect(
    PluginRepoFactoryDeployment.address,
    deployer
  );

  const initializeData =
    PluginRepo__factory.createInterface().encodeFunctionData('initialize', [
      deployer.address,
    ]);

  const pluginRepoBase = await pluginRepoFactory.pluginRepoBase();

  hre.aragonToVerifyContracts.push({
    address: hre.aragonPluginRepos['admin'],
    args: [pluginRepoBase, initializeData],
  });
};

export default func;
func.tags = ['CreateAdminRepo', 'Verify'];