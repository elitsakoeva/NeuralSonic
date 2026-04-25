from godot_rl.wrappers.stable_baselines_wrapper import StableBaselinesGodotEnv
from stable_baselines3 import PPO
from stable_baselines3.common.callbacks import CheckpointCallback
import os
import torch

def train():
    import subprocess
    import sys
    
    recordings_path = os.path.join(os.path.dirname(__file__), "recordings/")
    bc_script = os.path.join(os.path.dirname(__file__), "behavioral_cloning.py")
    
    if os.path.exists(recordings_path) and len(os.listdir(recordings_path)) > 0:
        print("training with player recordings first...")
        subprocess.run([sys.executable, bc_script], cwd=os.path.dirname(__file__))
        for f in os.listdir(recordings_path):
            os.remove(os.path.join(recordings_path, f))
        print("Done! Starting PPO training...")

    print(f"Using device: {'GPU - ' + torch.cuda.get_device_name(0) if torch.cuda.is_available() else 'CPU'}")
    
    env = StableBaselinesGodotEnv(
        env_path=None,
        show_window=True,
        speedup=10
    )
    
    model_path = "models/sonic_ai.zip"
    bc_path = "models/behavioral_cloning.pth"

    if os.path.exists(model_path):
        print("Loading existing model...")
        model = PPO.load(model_path, env=env, device="cuda")
    else:
        print("Creating new model...")
        model = PPO(
            "MultiInputPolicy",
            env,
            verbose=1,
            n_steps=1024,
            batch_size=128,
            learning_rate=0.001,
            n_epochs=10,
            gamma=0.95,
            device="cuda",
            tensorboard_log="./logs/"
        )
        
        if os.path.exists(bc_path):
            print("Loading Behavioral Cloning weights...")
            bc_weights = torch.load(bc_path)
            policy = model.policy
            with torch.no_grad():
                policy.mlp_extractor.policy_net[0].weight.copy_(bc_weights["network.0.weight"])
                policy.mlp_extractor.policy_net[0].bias.copy_(bc_weights["network.0.bias"])
                policy.mlp_extractor.policy_net[2].weight.copy_(bc_weights["network.2.weight"])
                policy.mlp_extractor.policy_net[2].bias.copy_(bc_weights["network.2.bias"])
            print("BC weights loaded!")
    
    checkpoint = CheckpointCallback(
        save_freq=1000,
        save_path="./models/",
        name_prefix="sonic_checkpoint"
    )
    
    print("Training starts!")
    model.learn(
        total_timesteps=5_000_000,
        callback=checkpoint,
        reset_num_timesteps=False
    )
    
    os.makedirs("models", exist_ok=True)
    model.save("models/sonic_ai")
    print("Model saved!")
    
    env.close()

if __name__ == "__main__":
    train()