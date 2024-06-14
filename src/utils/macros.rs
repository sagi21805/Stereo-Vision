#[macro_export]
macro_rules! pub_struct {
    (
        $(#[$meta:meta])*
        $vis:vis struct $name:ident<$($lt:lifetime),*> {
            $(
                $field_name:ident : $field_type:ty
            ),* $(,)?
        }
    ) => {
        $(#[$meta])*
        $vis struct $name<$($lt),*> {
            $(
                pub $field_name: $field_type,
            )*
        }
    };
}
