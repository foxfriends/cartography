use kameo::error::Infallible;
use kameo::prelude::*;
use std::any::{Any, TypeId};
use std::collections::HashMap;
use std::ops::ControlFlow;

pub trait AnyRecipient: Any {
    fn as_any(&self) -> &dyn Any;
    fn actor_id(&self) -> ActorId;
}

impl<T: Send + Sync> AnyRecipient for Recipient<T> {
    fn as_any(&self) -> &dyn Any {
        self
    }

    fn actor_id(&self) -> ActorId {
        self.id()
    }
}

pub struct Bus {
    listeners: HashMap<TypeId, Vec<Box<dyn AnyRecipient + Sync + Send>>>,
}

impl Bus {
    fn listen<T>(&mut self, recipient: Recipient<T>)
    where
        T: Any + Send + Sync,
    {
        let entry = self.listeners.entry(TypeId::of::<T>()).or_default();
        entry.push(Box::new(recipient))
    }

    async fn notify<T>(&mut self, notification: T)
    where
        T: Any + Send + Sync + Clone,
    {
        for recipient in self
            .listeners
            .get(&TypeId::of::<T>())
            .into_iter()
            .flatten()
            .filter_map(|entry| entry.as_any().downcast_ref::<Recipient<T>>())
        {
            if let Err(error) = recipient.tell(notification.clone()).await {
                tracing::error!("bus failed to notify: {}", error);
            }
        }
    }
}

impl Actor for Bus {
    type Args = ();
    type Error = ();

    async fn on_start(
        _args: Self::Args,
        _actor_ref: kameo::prelude::ActorRef<Self>,
    ) -> Result<Self, Self::Error> {
        Ok(Self {
            listeners: HashMap::new(),
        })
    }

    async fn on_link_died(
        &mut self,
        _actor_ref: kameo::prelude::WeakActorRef<Self>,
        id: kameo::prelude::ActorId,
        _reason: kameo::prelude::ActorStopReason,
    ) -> Result<std::ops::ControlFlow<kameo::prelude::ActorStopReason>, Self::Error> {
        for (_, listeners) in self.listeners.iter_mut() {
            listeners.retain(|listener| listener.actor_id() != id);
        }
        Ok(ControlFlow::Continue(()))
    }
}

pub struct Listen<T: Any + Send + Sync>(Recipient<T>);
pub struct Notify<T: Any + Send + Sync + Clone>(T);

pub trait BusExt {
    async fn listen<T: Any + Send + Sync, A: Actor + Message<T>>(
        &self,
        actor_ref: &ActorRef<A>,
    ) -> Result<(), SendError<Listen<T>, Infallible>>;

    async fn notify<T: Any + Send + Sync + Clone>(
        &self,
        notification: T,
    ) -> Result<(), SendError<Notify<T>, Infallible>>;
}

impl BusExt for ActorRef<Bus> {
    async fn listen<T: Any + Send + Sync, A: Actor + Message<T>>(
        &self,
        actor_ref: &ActorRef<A>,
    ) -> Result<(), SendError<Listen<T>, Infallible>> {
        self.link(actor_ref).await;
        self.tell(Listen(actor_ref.clone().recipient())).await
    }

    async fn notify<T: Any + Send + Sync + Clone>(
        &self,
        notification: T,
    ) -> Result<(), SendError<Notify<T>, Infallible>> {
        self.ask(Notify(notification)).await
    }
}

impl<T: Any + Send + Sync> Message<Listen<T>> for Bus {
    type Reply = ();

    async fn handle(
        &mut self,
        msg: Listen<T>,
        _ctx: &mut kameo::prelude::Context<Self, Self::Reply>,
    ) -> Self::Reply {
        self.listen(msg.0);
    }
}

impl<T: Any + Send + Sync + Clone> Message<Notify<T>> for Bus {
    type Reply = ();

    async fn handle(
        &mut self,
        msg: Notify<T>,
        _ctx: &mut kameo::prelude::Context<Self, Self::Reply>,
    ) -> Self::Reply {
        self.notify(msg.0).await;
    }
}
