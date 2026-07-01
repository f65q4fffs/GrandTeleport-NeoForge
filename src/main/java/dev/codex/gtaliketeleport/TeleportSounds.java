package dev.codex.gtaliketeleport;

import net.minecraft.resources.ResourceLocation;
import net.minecraft.sounds.SoundEvent;

public final class TeleportSounds {
    public static final SoundEvent CAMERA_IN = create("teleport.camera_in");
    public static final SoundEvent CAMERA_OUT = create("teleport.camera_out");
    public static final SoundEvent TELEPORT = create("teleport.teleport");
    public static final SoundEvent ZOOM_IN_LONG = create("teleport.zoom_in_long");
    public static final SoundEvent ZOOM_IN_SHORT = create("teleport.zoom_in_short");
    public static final SoundEvent ZOOM_OUT_LONG = create("teleport.zoom_out_long");
    public static final SoundEvent ZOOM_OUT_SHORT = create("teleport.zoom_out_short");

    private TeleportSounds() {
    }

    private static SoundEvent create(String path) {
        return SoundEvent.createVariableRangeEvent(ResourceLocation.fromNamespaceAndPath("gtalike_teleport", path));
    }
}