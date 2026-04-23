from godot_rl.wrappers.stable_baselines_wrapper import StableBaselinesGodotEnv
from stable_baselines3 import PPO
from stable_baselines3.common.callbacks import CheckpointCallback
import os
import torch

def train():
    print(f"Using device: {'GPU - ' + torch.cuda.get_device_name(0) if torch.cuda.is_available() else 'CPU'}")
    
    env = StableBaselinesGodotEnv(
        env_path=None,
        show_window=True,
        speedup=10
    )
    
    model_path = "models/sonic_ai.zip"
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
    
    checkpoint = CheckpointCallback(
        save_freq=10000,
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